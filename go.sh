#!/usr/bin/env bash
set -e


find ./out/notes/ -name *.xml | xargs -I '{}' basename {} | xargs -I '{}' bash -c 'xsltproc xsl/cleaner.xslt out/notes/{} > out/cleaned/{}; xsltproc xsl/article.xslt out/cleaned/{} > out/articles/{}'
