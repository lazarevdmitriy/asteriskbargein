# AsteriskBargein
Вариант реализации прерывания воспроизведения приветвия на основе функции `SynthAndRecog()`.

# Установка
- Переходим в `Настройки-Телефония-Расширенные настройки` добавляем в `Настройка MRCP` новый профиль `tts`, указав параметры MRCP сервера синтеза. Указываем его по умолчанию для синтеза `default-tts-profile = tts`. Пример в `examples/mrcp.conf`.
- Заменяем в базе процедуру `_phoneGetIVR.sql`. Например `zcat _phoneGetIVR.sql | mysql -u $user --password=$pass -h $host $base`.
- В настройках словаря в разделе `Настройка-Система-Речь-ОНЛАЙН-РАСПОЗНАВАНИЕ` в словарях убрать не поддерживаемый парамерт `i=any`. Проверяем настройки mrcp.
- Заставляем сформировать диалплан командой `mysql -u $user --password=$pass -h $host $base -e  "update updated set is_updated=2;"`
- Cоздаем unimrcp профиль `/usr/local/unimrcp/conf/client-profiles/tts.xml`. Пример в `examples/tts.xml`.
- Не забываем открыть порты указанные в профиле. Например указанные в `examples/mrcp.conf` `38000-39000/udp` и `8062/tcp` командой `firewall-cmd --zone=public --permanent --add-port=38000-39000/udp --add-port=8062/tcp && firewall-cmd --reload`

# Замечания
В начале функции `_phoneGetIVR.sql` вынесены настройки параметров синтеза. Можно настроить голос, pitch, volume, rate.

```
DECLARE voice VARCHAR(20) DEFAULT 'vera';
DECLARE voice INT DEFAULT 100;
DECLARE pitch INT DEFAULT 140;
DECLARE volume INT DEFAULT 100;
DECLARE rate INT DEFAULT 100;
```

# Использование
- В выбранном IVR диалоге на вкладке `Приветвия` указываем `Возможность прерывания приветствия`. 
- Сохраняем настройки нажав на дискету.
- Теперь выбранный диалог возможно прерывать во время прослушивания приветвия. Фраза, которой прервали распознается текущей грамматикой. Распознанный текст передается в следующий диалог.  

# Документация:
- https://www.unimrcp.org/manuals/html/AsteriskUsageManual.html
- https://www.unimrcp.org/manuals/html/AsteriskManual.html
