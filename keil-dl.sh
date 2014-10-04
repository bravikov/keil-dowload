#!/bin/bash

#       Автор: Дмитрий Бравиков (bravikov@gmail.com)
#
#       Вызов: ./keil-dl.sh [i] {arm|c51|c251|c166}
#
#              Необязательная опция i указывает скрипту запустить установщик
#              после загрузки.
#
# Зависимости: html-xml-utils (обязательно, для обработки html-страницы)
#              wget (обязательно, для скачивания),
#              wine (не обязательно, для установки)
#
#    Описание: Скрипт для зарузки и установки последних версий
#              бесплатных средств разработки Keil.
#
#              Keil позволяет скачивать свои продукты только после ввода
#              персональных данных. Скрипт автоматически связывается с
#              сайтом keil.com и передает ему ваши персональные данные,
#              которые берет из файла keil-dl-settings.
#
#              Чтобы создать файл keil-dl-settings, просто скопируйте
#              и переименуйте файл keil-dl-settings-template.
#
#              Файл keil-dl-settings должен быть заполнен согласно
#              описанию в этом файле.
#
#              Установщик загружается в каталог, указаную в переменной
#              DOWNLOAD_DIR, которую берет из файла keil-dl-settings.
#
#              Если в каталоге, уже содержится, загружаемая версия,
#              то загрузка будет прервана.
#
#              Если загрузка была прервана (например комбицией ctrl-c),
#              то при следующем запуске скрипта загрузка частичто загрузочного
#              файла возобновится.
#              
#              Пример. Следующая команда загрузит последнюю версию MDK-ARM:
#                   ./keil-dl.sh arm


# Загрузка настроек
if source keil-dl-settings;
    then echo "Настройки загружены."
    else
        echo "Неудалось загрузить настройки из файла keil-dl-settings."
        echo "Переименуйте и заполните файл keil-dl-settings-template."
        exit 1
fi

# Обработка аргументов командной строки

BAD_ARGUMENTS="no"
INSTALL="no"
ARCH=""

if [ $# == 2 ]
then
    if [ $1 != "i" ]
        then BAD_ARGUMENTS="yes"
        else INSTALL="yes"
    fi
    ARCH=$2
fi

if [ $# == 1 ]
    then ARCH=$1
fi

if [ "$ARCH" != "arm" ] && [ "$ARCH" != "c51" ] && [ "$ARCH" != "c251" ] && [ "$ARCH" != "c166" ]

    then BAD_ARGUMENTS="yes"
fi

# Вывести инструкцию по использованию скрипта, если указаны не верные аргументы
if [ $BAD_ARGUMENTS == "yes" ] || [ $# == 0 ] || (($# > 2))
then
    echo -e "\n"\
        "Вызов: ./keil-dl.sh [i] {arm|c51|c251|c166}\n\n"\
        "Опция i указывает скрипту запустить установщик после загрузки.\n\n"\
        "Пример загрузки последней версии MDK-ARM: ./keil-download.sh arm\n"
    exit
fi

# Конец обработки аргументов командной строки

POST_DATA="\
firstname=$FIRSTNAME\
&lastname=$LASTNAME\
&email=$EMAIL\
&countrycode=$COUNTRY_CODE\
&zip=$POSTAL_CODE\
&city=$CITY\
&addr1=$ADDRESS\
&company=$COMPANY\
&phone=$PHONE"

TEMPORARY_PAGE="/tmp/keil-download-$ARCH-tempopary.html"

wget --no-check-certificate -O $TEMPORARY_PAGE --post-data "$POST_DATA" \
    "https://www.keil.com/$ARCH/demo/eval/$ARCH.htm"

DOWNLOAD_EXE_URL=`hxwls $TEMPORARY_PAGE | grep .exe`
FILE_NAME=`basename "$DOWNLOAD_EXE_URL"`

mkdir -p "$DOWNLOAD_DIR/$ARCH"
wget -c -P "$DOWNLOAD_DIR/$ARCH" "$DOWNLOAD_EXE_URL"
chmod u+x "$DOWNLOAD_DIR/$ARCH/$FILE_NAME"

if [ "$INSTALL" == "yes" ]
    then
        echo -e "Установка $FILE_NAME...\n"
        wine "$DOWNLOAD_DIR/$ARCH/$FILE_NAME"
fi

rm -f "$TEMPORARY_PAGE"

