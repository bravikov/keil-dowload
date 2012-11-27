#!/bin/bash

#       Автор: Дмитрий Бравиков (bravikov@gmail.com)
#
#       Вызов: ./keil-dl.sh [i] {arm|c51|c251|c166}
#
#              Опция i указывает скрипту запустить установщик после скачивания.
#
# Зависимости: wget (обязательно, для скачивания), wine (для установки)
#
#    Описание: скрипт для зарузки и установки последних версий ограниченных
#              продуктов Keil.
#
#              По умолчанию установщик загружается в
#                   $HOME/Программы/Программирование/Keil
#
#              Если в каталоге, уже содержится, загружаемая версия,
#              то загрузка будет прервана.
#              
#              Например, следующая команда загрузит последнюю версию MDK-ARM:
#                   ./keil-dl.sh arm
#
#              Загрузку можно прервать комбинацией ctrl+c. Загрузка продолжиться
#              при следующем вызове скрипта.
#              Пользователю скрипта необходимо заполнить переменные ниже:
 

################################################################################

    # Каталог для загрузки установщиков
    DIR="$HOME/Программы/Программирование/Keil"

    # Информация, запрашиваемая keil.com.
    # В кавычках требуется указать информацию о себе.
    FIRSTNAME="Dmitry"         # Имя
    LASTNAME="Bravikov"        # Фамилия
    EMAIL="bravikov@gmail.com" # Адрес электронной почты
    COUNTRY_CODE="RU"          # Код страны (RU - для России)
    POSTAL_CODE="454080"       # Почтовый индекс
    CITY="Chelyabinsk"         # Город
    ADDRESS="Vitebskay, 4"     # Адрес
    COMPANY="Chelenegropribor" # Организация
    PHONE="+79514767304"       # Номер телефона

################################################################################


# Парсинг аргументов командной строки

BED_ARGUMENTS="no"
INSTALL="no"
ARCH=""

if [ $# == 2 ]
then
    if [ $1 != "i" ]
        then BED_ARGUMENTS="yes"
        else INSTALL="yes"
    fi
    ARCH=$2
fi

if [ $# == 1 ]
    then ARCH=$1
fi

if [ "$ARCH" != "arm" ] && [ "$ARCH" != "c51" ] && [ "$ARCH" != "c251" ] && [ "$ARCH" != "c166" ]

    then BED_ARGUMENTS="yes"
fi

# Вывести инструкцию по использованию скрипта, если указаны не верные аргументы
if [ $BED_ARGUMENTS == "yes" ] || [ $# == 0 ] || (($# > 2))
then
    echo -e \
        "\n"\
        "Вызов: ./keil-dl.sh [i] {arm|c51|c251|c166}\n\n"\
        "Опция i указывает скрипту запустить установщик после скачивания.\n\n"\
        "Например, скачивание последней версии MDK-ARM: ./keil-download.sh arm\n"
    exit
fi

# Конецу парсинга аргументов командной строки


URL="https://www.keil.com/$ARCH/demo/eval/$ARCH.htm"

POST_DATA=""\
"firstname=$FIRSTNAME"\
"&"\
"lastname=$LASTNAME"\
"&"\
"email=$EMAIL"\
"&"\
"countrycode=$COUNTRY_CODE"\
"&"\
"zip=$POSTAL_CODE"\
"&"\
"city=$CITY"\
"&"\
"addr1=$ADDRESS"\
"&"\
"company=$COMPANY"\
"&"\
"phone=$PHONE"\
""

# Запомнить текущий каталог
BACKDIR=$PWD

# Перейти в каталог скрипта
ABSOLUTE_FILENAME=`readlink -e "$0"`
cd "`dirname "$ABSOLUTE_FILENAME"`"

# Временная страница с ссылкой для скачивания
TEMP_PAGE="keil-dl-$ARCH-temp.html"

# Получить страницу с сылкой для скачивания
wget --no-check-certificate -O $TEMP_PAGE --post-data "$POST_DATA" $URL

# Поиск ссылки на странице 
URL_EXE=`sed -r 's~.*<div class=dlfile><b><a href="(.*)">.*</a></b>.*</div>.*~\1~g' $TEMP_PAGE`
FILE=`echo $URL_EXE | sed -r 's~.*/(.*)$~\1~g'`

# Удалить временный файл
rm -f $TEMP_PAGE

FILE_PATH="$DIR/$ARCH/$FILE"

# Создать каталог для закачки, если необходимо
mkdir -p "$DIR/$ARCH"

# Скачать установщик
wget -c -O "$FILE_PATH" "$URL_EXE"

# Сделать файл исполняемым     
chmod u+x "$FILE_PATH"

if [ $INSTALL == "yes" ]
    echo -e "Установка $FILE...\n"
    then wine "$FILE_PATH"
fi

# Вернуться в исходный каталог
cd "$BACKDIR"

