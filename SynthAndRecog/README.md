# AsteriskBargein
Вариант реализации прерывания воспроизведения приветвия на основе функции `SynthAndRecog()`.

# Установка
- Переходим в `Настройки-Телефония-Расширенные настройки` добавляем в `Настройка MRCP` новый профиль `tts`, указав параметры MRCP сервера синтеза. Указываем его по умолчанию для синтеза `default-tts-profile = tts`. Пример в `examples/mrcp.conf`.
- Заменяем в базе процедуру `__phoneGetIVR.sql`. Например `zcat __phoneGetIVR.sql | mysql -u $user --password=$pass -h $host $base`.
- Заставляем сформировать диалплан командой `mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"`
- При необходимости создаем unimrcp профиль `/usr/local/unimrcp/conf/client-profiles/tts.xml` и правим настройки клиента `/usr/local/unimrcp/conf/unimrcpclient.xml`. Пример в `examples/tts.xml` и `examples/unimrcpclient.xml`.
- Не забываем открыть порты указанные в профиле. Например указанные в `examples/mrcp.conf` `38000-39000/udp` и `8062/tcp`.

# Использование
- В выбранном IVR диалоге на вкладке `Приветвия` указываем `Возможность прерывания приветствия`. 
- Сохраняем настройки нажав на дискету.
- Теперь выбранный диалог возможно прерывать во время прослушивания приветвия. Фраза, которой прервали распознается текущей грамматикой. Распознанный текст передается в следующий диалог.  

# Документация:
- https://www.unimrcp.org/manuals/html/AsteriskUsageManual.html
- https://www.unimrcp.org/manuals/html/AsteriskManual.html
