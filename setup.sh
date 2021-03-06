#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")

if [ -z "$(pacman -Qq nginx 2>/dev/null)" ] ; then
    echo "Installing nginx"
    pacman -Syu --needed --noconfirm nginx &>/dev/null
fi

unchanged_sha="8afcd712bc47ee098a3d06f7e388a3d9d28f07de"
current_sha="$(shasum /etc/nginx/nginx.conf | awk '{print $1}')"
diff_lines="$(diff nginx.conf /etc/nginx/nginx.conf | wc -l)"
if [ "$diff_lines" == "4" ] ; then
    echo 'DebugHub config already in place'
elif [ "$unchanged_sha" = "$current_sha" ] ; then
    echo 'Loading nginx configuraton'
    cp nginx.conf /etc/nginx/nginx.conf
    sed -i "s|DEBUGHUB_ROOT|$(pwd)/src|" /etc/nginx/nginx.conf
    systemctl restart nginx
else
    echo "Nginx config has been modified; bailing"
    exit 1
fi

if [ -z "$(pacman -Qq python-pip 2>/dev/null)" ] ; then
    echo "Installing Python"
    pacman -Syu --needed --noconfirm python-pip &>/dev/null
fi

if [ -z "$(pip list | grep jsbeautifier)" ] ; then
    echo "Installing jsbeautifier"
    pip install six jsbeautifier &>/dev/null
fi

./user_setup.sh

