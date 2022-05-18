# AsteriskBargein
Вариант реализации прерывания воспроизведения приветвия на основе функции `SynthAndRecog()`.

# Установка
- Переходим в `Настройки-Телефония-Расширенные настройки` и добавляем в `Настройка MRCP` новый профиль `tts` и указываем как профиль по умолчанию для синтеза `default-tts-profile = tts`. Пример в `examples/mrcp.conf`.
- Заменяем функцию `__phoneGetIVR.sql` командой `zcat __phoneGetIVR.sql | mysql -u $user --password=$pass -h $host $base`.
- Заставляем переварить диалплан командой `mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"`
- При необходимости создаем unimrcp профиль `vi /usr/local/unimrcp/conf/client-profiles/tts.xml` и правим `/usr/local/unimrcp/conf/unimrcpclient.xml` по аналогии с `examples/tts.xml` и `examples/unimrcpclient.xml`.
- Не забываем открыть порты указанные в профиле, например указанные в `examples/mrcp.conf` 38000-39000/udp и 8062/tcp.

# Документация:
- https://www.unimrcp.org/manuals/html/AsteriskUsageManual.html
- https://www.unimrcp.org/manuals/html/AsteriskManual.html
