#!/bin/bash

#
# This script can be used to generate the unified template for the entire Launch application
#
# Just run it and pipe its output to "openshift/launch-template.yaml".
# It is required to have the launcher-backend and launcher-frontend modules available
# as sibling folders of this "launcher-openshift-templates" project.
#

main() {
    DIR=$(cd "$(dirname "$0")" ; pwd -P)
    cat $DIR/../openshift/split/launcher-header.yaml
    echo "parameters:"
    printTemplateParams $DIR/../openshift/split/launcher-configmaps.yaml
    printTemplateParams $DIR/../../launcher-backend/openshift/template.yaml "BACKEND"
    printTemplateParams $DIR/../../launcher-creator-backend/openshift/template.yaml "CREATOR_BACKEND"
    printTemplateParams $DIR/../../launcher-frontend/openshift/template.yaml "FRONTEND"
    printTemplateParams $DIR/../openshift/split/launcher-configmapcontroller.yaml "CONTROLLER"
    printTemplateParams $DIR/../openshift/split/launcher-routes.yaml
    printTemplateParams $DIR/../openshift/split/launcher-secrets.yaml
    echo "objects:"
    printTemplateObjects $DIR/../openshift/split/launcher-configmaps.yaml
    printTemplateObjects $DIR/../../launcher-backend/openshift/template.yaml "BACKEND"
    printTemplateObjects $DIR/../../launcher-creator-backend/openshift/template.yaml "CREATOR_BACKEND"
    printTemplateObjects $DIR/../../launcher-frontend/openshift/template.yaml "FRONTEND"
    printTemplateObjects $DIR/../openshift/split/launcher-configmapcontroller.yaml "CONTROLLER"
    printTemplateObjects $DIR/../openshift/split/launcher-routes.yaml
    printTemplateObjects $DIR/../openshift/split/launcher-secrets.yaml
}

printTemplateParams() {
    export modulename=$2
    perl < $1 -e '
    use strict;
    use warnings;
    my $modname=$ENV{"modulename"};
    my $start=0;
    while (my $line = <>) {
        if ($start == 1) {
            if ($line =~ /^[\s-]/) {
                $line =~ s/\bIMAGE\b/${modname}_IMAGE/g;
                $line =~ s/\bIMAGE_TAG\b/${modname}_IMAGE_TAG/g;
                $line =~ s/\bCPU_REQUEST\b/${modname}_CPU_REQUEST/g;
                $line =~ s/\bCPU_LIMIT\b/${modname}_CPU_LIMIT/g;
                $line =~ s/\bMEMORY_REQUEST\b/${modname}_MEMORY_REQUEST/g;
                $line =~ s/\bMEMORY_LIMIT\b/${modname}_MEMORY_LIMIT/g;
                $line =~ s/\bREPLICAS\b/${modname}_REPLICAS/g;
                print $line;
            } else {
                exit;
            }
        }
        if ($line =~ /parameters:/) {
            $start=1;
        }
    }'
}

printTemplateObjects() {
    export modulename=$2
    perl < $1 -e '
    use strict;
    use warnings;
    my $modname=$ENV{"modulename"};
    my $start=0;
    while (my $line = <>) {
        if ($start == 1) {
            if ($line =~ /^[\s-]/) {
                $line =~ s/\$\{IMAGE}/\${${modname}_IMAGE}/g;
                $line =~ s/\$\{IMAGE_TAG}/\${${modname}_IMAGE_TAG}/g;
                $line =~ s/\$\{CPU_REQUEST}/\${${modname}_CPU_REQUEST}/g;
                $line =~ s/\$\{CPU_LIMIT}/\${${modname}_CPU_LIMIT}/g;
                $line =~ s/\$\{MEMORY_REQUEST}/\${${modname}_MEMORY_REQUEST}/g;
                $line =~ s/\$\{MEMORY_LIMIT}/\${${modname}_MEMORY_LIMIT}/g;
                $line =~ s/\$\{\{REPLICAS}}/\${{${modname}_REPLICAS}}/g;
                print $line;
            } else {
                exit;
            }
        }
        if ($line =~ /objects:/) {
            $start=1;
        }
    }'
}

main"$@"

