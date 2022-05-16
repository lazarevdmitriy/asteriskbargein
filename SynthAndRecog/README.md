# AsteriskBargein
Вариант реализации прерывания воспроизведения приветвия на основе функции `SynthAndRecog()`.

Для использования другого сервера синтеза или голосового движка с другими параметрами измените unimrcp профиль `/usr/local/unimrcp/conf/client-profiles/tts.xml` и соответвующие настройки модуля `app_unimrcp.so` в разделе `/etc/asterisk/mrcp.conf`

## Примечание
`mrcp.conf` должен перезаписываться при каждом нажатии на дискету, возможн онужно придумать механизм включения правок mrcp профиля в расширенные настройки теелфонии.

Также нужно проверить будет ли брать модуль настройки сервера из mrcp.conf если не указывать ip в unimrcpclient.xml и ttx.xml. 

# Документация:
- https://www.unimrcp.org/manuals/html/AsteriskUsageManual.html
- https://www.unimrcp.org/manuals/html/AsteriskManual.html

