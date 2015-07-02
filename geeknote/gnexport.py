#!/usr/bin/env python
# -*- coding: utf-8 -*-

import traceback
import time
import sys
import os
import re
import mimetypes
import pprint
import io

import thrift.protocol.TBinaryProtocol as TBinaryProtocol
import thrift.transport.THttpClient as THttpClient

import evernote.edam.userstore.constants as UserStoreConstants
import evernote.edam.notestore.NoteStore as NoteStore
import evernote.edam.error.ttypes as Errors
import evernote.edam.type.ttypes as Types
import evernote.edam.notestore.ttypes as NoteTypes

import config
import tools
import out
import geeknote

from editor import Editor, EditorThread
from gclient import GUserStore as UserStore
from argparser import argparser
from oauth import GeekNoteAuth
from storage import Storage
from log import logging


def main(args=None):
    try:
        exit_status_code = 0

        sys_argv = sys.argv[1:]
        if isinstance(args, list):
            sys_argv = args

        sys_argv = tools.decodeArgs(sys_argv)

        notebook = sys_argv[0] if len(sys_argv) >= 1 else None

        if not notebook:
            return tools.exit()

        evernote = geeknote.GeekNoteConnector().getEvernote()
        store = None
        nb = None
        shareToken = evernote.authToken

        localNotebooks = evernote.findNotebooks()

        for key, item in enumerate(localNotebooks):
            if item.name == notebook:
                nb = item
                store = evernote.getNoteStore()

        if not store:
            linkedNotebooks = evernote.findLinkedNotebooks()

            for key, item in enumerate(linkedNotebooks):
                if item.shareName == notebook:
                    nb = item
                    store = evernote.getNoteStoreByUrl(item.noteStoreUrl)
                    auth = store.authenticateToSharedNotebook(item.shareKey, evernote.authToken)
                    shareToken = auth.authenticationToken

                    nb = store.getSharedNotebookByAuth(shareToken)

                    break

        tags = store.listTagsByNotebook(shareToken, nb.notebookGuid)

        tagsMap = {}

        for key, item in enumerate(tags):
            tagsMap[item.guid] = item.name

        updatedFilter = NoteTypes.NoteFilter()
        offset = 0
        maxNotes = 40000
        resultSpec = NoteTypes.NotesMetadataResultSpec(includeCreated=True, includeUpdated=True, includeTitle=True, includeAttributes=True, includeTagGuids=True)

        notesMetadata = store.findNotesMetadata(shareToken, updatedFilter, offset, maxNotes, resultSpec)

        for key, item in enumerate(notesMetadata.notes):
            note = store.getNote(shareToken, item.guid, withContent=True, withResourcesData=True, withResourcesRecognition=False, withResourcesAlternateData=False)
            slug = note.attributes.sourceURL if note.attributes.sourceURL else note.guid

            if note.resources:
                for key, res in enumerate(note.resources):
                    if res.mime in config.DUMP_RESOURCE_MIME_PATH:
                        if not res.attributes.fileName:
                            res.attributes.fileName = "%s.%s" % (res.guid, re.sub(r'[^/]+/', '', res.mime))

                        resPath = "%s/%s" % (config.DUMP_RESOURCE_MIME_PATH[res.mime], res.attributes.fileName)

                        with open(resPath, "wb") as resWriter:
                            resWriter.write(res.data.body)

            with io.open("%s/%s.xml" % (config.DUMP_PATH, slug.replace("/", "-")), "w", encoding="utf-8") as noteWriter:
                noteWriter.write(u'<?xml version="1.0" ?>\n')
                noteWriter.write(u"<note>\n")

                noteWriter.write(u"\t<tags>\n")
                for key, tag in enumerate(note.tagGuids):
                    noteWriter.write(u"\t\t<tag>%s</tag>\n" % tagsMap[tag].decode('utf-8'))

                noteWriter.write(u"\t</tags>\n")
                noteWriter.write(u"\t<author>%s</author>\n" % note.attributes.author.decode('utf-8'))
                noteWriter.write(u"\t<title>%s</title>\n" % note.title.decode('utf-8'))
                noteWriter.write(u"\t<created>%s</created>\n" % note.created)

                if note.attributes.lastEditedBy:
                    noteWriter.write(u"\t<lastEditedBy>%s</lastEditedBy>\n" % note.attributes.lastEditedBy.decode('utf-8'))

                if note.resources:
                    noteWriter.write(u"\t<resources>\n")
                    for key, res in enumerate(note.resources):
                        resHash = ''.join(x.encode('hex') for x in res.data.bodyHash)
                        noteWriter.write(('\t\t<resource hash="%s" path="%s/%s"/>\n' % (resHash, config.DUMP_RESOURCE_MIME_PATH[res.mime], res.attributes.fileName)).decode('utf-8'))
                    noteWriter.write(u"\t</resources>\n")

                noteWriter.write(u"\t<content>%s</content>\n" % re.sub(r'\<[?!][^>]+\>', "", note.content.decode('utf-8')))
                noteWriter.write(u"</note>")

        out.successMessage("Done.")
    except (KeyboardInterrupt, SystemExit, tools.ExitException), e:
        if e.message:
            exit_status_code = e.message

    except Exception, e:
        traceback.print_exc()
        logging.error("App error: %s", str(e))

    # exit preloader
    tools.exit('exit', exit_status_code)

if __name__ == "__main__":
    main()
