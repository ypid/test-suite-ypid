#!/bin/bash

set -e

php_version="${1:-5}"

if [ -d "/etc/php${php_version}/ansible" ] ; then
    php_etc_base="/etc/php${php_version}"
elif [ -d "/etc/php/${php_version}/ansible" ] ; then
    php_etc_base="/etc/php/${php_version}"
fi

if [ -n "${php_etc_base}" ] ; then

    if [ -d "${php_etc_base}/conf.d" ] ; then

        cd "${php_etc_base}/conf.d"
        for config_file in ${php_etc_base}/ansible/* ; do
            if [[ ! -L "$(basename "${config_file}")" ]] || [[ ! -r "$(basename "${config_file}")" ]] ; then
                pwd
                echo ln -sfv "../ansible/$(basename "${config_file}")" "$(basename "${config_file}")"
                ln -sfv "../ansible/$(basename "${config_file}")" "$(basename "${config_file}")"
                ls -l "$(basename "${config_file}")"
            fi
        done
        for path in ${php_etc_base}/conf.d/* ; do
            if [[ -n "${path}" ]] && [[ -L "${path}" ]] ; then
                if [ ! -r "${path}" ] ; then
                    pwd
                    echo rm -fv "${path}"
                    rm -fv "${path}"
                fi
            fi
        done
        cd - > /dev/null

    else

        for sapi in ${php_etc_base}/{cli,cgi,fpm,embed,apache2} ; do
            if [[ -n "${sapi}" ]] && [[ -d "${sapi}/conf.d" ]] ; then
                cd "${sapi}/conf.d"
                for config_file in ${php_etc_base}/ansible/* ; do
                    if [[ ! -L "$(basename "${config_file}")" ]] || [[ ! -r "$(basename "${config_file}")" ]] ; then
                        pwd
                        echo ln -sfv "../../ansible/$(basename "${config_file}")" "$(basename "${config_file}")"
                        ln -sfv "../../ansible/$(basename "${config_file}")" "$(basename "${config_file}")"
                        ls -l "$(basename "${config_file}")"
                    fi
                done
                for path in ${sapi}/conf.d/* ; do
                    if [[ -n "${path}" ]] && [[ -L "${path}" ]] ; then
                        if [ ! -r "${path}" ] ; then
                            pwd
                            echo rm -fv "${path}"
                            rm -fv "${path}"
                        fi
                    fi
                done
                cd - > /dev/null
            fi
        done

    fi
fi
