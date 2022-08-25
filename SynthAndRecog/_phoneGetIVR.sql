DELIMITER ;;
DROP FUNCTION IF EXISTS `_phoneGetIVR`;
CREATE DEFINER=`root`@`localhost` FUNCTION `voicetech`.`_phoneGetIVR`(`ivrID` INT) RETURNS longtext CHARSET utf8
    NO SQL
BEGIN

DECLARE voice VARCHAR(20) DEFAULT 'vera';
DECLARE pitch INT DEFAULT 140;
DECLARE volume INT DEFAULT 100;
DECLARE rate INT DEFAULT 100;

-- Load FROM options
SELECT voice,pitch,volume,volume
INTO voice,pitch,volume,volume
FROM options


DECLARE result LONGTEXT DEFAULT '';
DECLARE scriptsDir TEXT DEFAULT '/etc/asterisk/scripts';
DECLARE integrationsDir TEXT DEFAULT '/etc/asterisk/integrations/internal';

DECLARE hasLocalCallV INT DEFAULT 0;
DECLARE moh_idV INT DEFAULT 0;
DECLARE hasCallbackV INT DEFAULT 0;
DECLARE hasDisaV INT DEFAULT 0;
DECLARE hasDisapasswordV INT DEFAULT 0;
DECLARE greeting_textV TEXT DEFAULT '';
DECLARE synthesis_idV INT DEFAULT NULL;
DECLARE biometryV INT DEFAULT 0;
DECLARE dialplanV VARCHAR(100) DEFAULT '';
DECLARE voice_file_idV TEXT DEFAULT '';
DECLARE timeoutgroup_idV INT DEFAULT NULL;
DECLARE timeoutqueue_idV INT DEFAULT NULL;
DECLARE timeoutivr_idV INT DEFAULT NULL;
DECLARE fallbackgroup_idV INT DEFAULT NULL;
DECLARE fallbackqueue_idV INT DEFAULT NULL;
DECLARE fallbackivr_idV INT DEFAULT NULL;
DECLARE greeting_idV TEXT DEFAULT '';
DECLARE pathV VARCHAR(400) DEFAULT '';
DECLARE nameV VARCHAR(400) DEFAULT '';
DECLARE recognition_idV INT DEFAULT NULL;
DECLARE recognitionTypeV VARCHAR(20) DEFAULT '';
DECLARE recognitionStringV TEXT DEFAULT '';
DECLARE timeout_routeV TEXT DEFAULT '';
DECLARE fallback_routeV TEXT DEFAULT '';
DECLARE ivr_routeV TEXT DEFAULT '';
DECLARE hasSmsAutoReplyV INT DEFAULT 0;
DECLARE waitingV INT DEFAULT 0;
DECLARE playBeepV INT DEFAULT 0;
DECLARE interruptGreetingV INT DEFAULT 0;
DECLARE searchV TEXT DEFAULT '';
DECLARE greetingTypeV VARCHAR(40) DEFAULT '';
DECLARE sayOrderTypeV VARCHAR(40) DEFAULT '';
DECLARE relayVoiceV INT DEFAULT 0;
DECLARE hangupFileV VARCHAR(100) DEFAULT '';
DECLARE tempV TEXT DEFAULT '';
DECLARE voiceV TEXT DEFAULT '';
DECLARE i INT DEFAULT 0;
DECLARE n INT DEFAULT 0;
DECLARE dataset_idV VARCHAR(20) DEFAULT '';
DECLARE qas_class_idV VARCHAR(20) DEFAULT '';
DECLARE resultV VARCHAR(45) DEFAULT '';
DECLARE resultVarV VARCHAR(45) DEFAULT '';
DECLARE recognitionIsAdvancedV INT DEFAULT 0;
DECLARE extensionV VARCHAR(45) DEFAULT '';


SELECT phone_ivrs.hasLocalCall,
       phone_ivrs.moh_id,
       phone_ivrs.name,
       ifnull(phone_ivrs.number,''),
       phone_ivrs.hasCallback,
       phone_ivrs.hasDisa,
       phone_ivrs.hasDisapassword,
       replace(replace(phone_ivrs.greeting_text,'',' '),"'",'"'),
       phone_ivrs.synthesis_id,
       phone_ivrs.biometry,
       phone_ivrs.voice_file_id,
       phone_ivrs.greeting_id,
       phone_ivrs.timeoutgroup_id,
       phone_ivrs.timeoutqueue_id,
       phone_ivrs.timeoutivr_id,
       phone_ivrs.fallbackgroup_id,
       phone_ivrs.fallbackqueue_id,
       phone_ivrs.fallbackivr_id,
       phone_ivrs.recognition_id,
       connectors.param1,
       (TRIM(connectors.param5)!=''),
       connectors.param,
       phone_ivrs.waiting,
       concat(
         IFNULL(concat('Macro(LocalCall,',timeout_groups.number,',',timeout_groups.phones,',tkm)'),''),
         IFNULL(concat('Queue(Queue',phone_ivrs.timeoutqueue_id,',tkm)'),''),
         IFNULL(concat('Goto(Ivr',phone_ivrs.timeoutivr_id,',s,1)'),'')),
       concat(
         IFNULL(concat('Macro(LocalCall,',fallback_groups.number,',',fallback_groups.phones,',tkm)'),''),
         IFNULL(concat('Queue(Queue',phone_ivrs.fallbackqueue_id,',tkm)'),''),
         IFNULL(concat('Goto(Ivr',phone_ivrs.fallbackivr_id,',s,1)'),'')),
       group_concat(concat(
         'exten = ',phone_ivr_options.symbol,',1,Set(txt=${EXTEN})\n',
		 ifnull(concat('exten = ',phone_ivr_options.symbol,',n,Macro(SaveJourney,0,',phone_ivr_options.callivr_id,',${wavfile},)\n'),''),
         'exten = ',phone_ivr_options.symbol,',n,AGI(',scriptsDir,'/recognize',phone_ivrs.id,'.sh,"${EXTEN}","${data}","${CALLERID(num)}","${interactionID}","/var/spool/asterisk/journeys/${wavfile}.wav")\n',
         'exten = ',phone_ivr_options.symbol,',n,',
          IFNULL(concat('Macro(LocalCall,',call_groups.number,',',call_groups.phones,',tkm)\n'),''),
          IFNULL(concat('Queue(Queue',phone_ivr_options.callqueue_id,',tkm)\n'),''),
          IFNULL(concat('Goto(Ivr',phone_ivr_options.callivr_id,',s,1)\n'),'')) SEPARATOR ''),
       greetingType,sayOrderType,relayVoice,hangupFile,playBeep,interruptGreeting,
       if(dialplan_id is null,'DialplanLocal',concat('Dialplan',dialplan_id)),
       ifnull(phone_ivrs.dataset_id,''), ifnull(phone_ivrs.result,''), ifnull(resultVar,''),
       ifnull(qas_class_id,'')
INTO hasLocalCallV, moh_idV, nameV, extensionV, hasCallbackV, hasDisaV, hasDisapasswordV, greeting_textV,
     synthesis_idV, biometryV, voice_file_idV, greeting_idV, timeoutgroup_idV, timeoutqueue_idV, timeoutivr_idV,
     fallbackgroup_idV, fallbackqueue_idV, fallbackivr_idV, recognition_idV,
     recognitionTypeV, recognitionIsAdvancedV, recognitionStringV, waitingV, timeout_routeV, fallback_routeV, ivr_routeV,
     greetingTypeV,sayOrderTypeV,relayVoiceV, hangupFileV ,playBeepV, interruptGreetingV, dialplanV,
     dataset_idV, resultV, resultVarV, qas_class_idV
FROM phone_ivrs
LEFT JOIN  phone_ivr_options ON phone_ivr_options.ivr_id = phone_ivrs.id
LEFT JOIN phone_groups AS timeout_groups ON timeout_groups.id = phone_ivrs.timeoutgroup_id
LEFT JOIN phone_groups AS fallback_groups ON fallback_groups.id = phone_ivrs.fallbackgroup_id
LEFT JOIN phone_groups AS call_groups ON call_groups.id = phone_ivr_options.callgroup_id
LEFT JOIN connectors ON connectors.id = phone_ivrs.recognition_id
WHERE phone_ivrs.id=ivrID;


IF qas_class_idV != '' THEN

  SET result = '';

  SELECT count(*) INTO n FROM qas WHERE class_id = qas_class_idV;

  SET i = 0;
  WHILE i<n DO

    SELECT REPLACE(REPLACE(voiceMessage,'!','\\!'),'\n',' '), id INTO greeting_textV, tempV
    FROM qas WHERE class_id = qas_class_idV LIMIT i,1;
    SET result = concat(result,
      '\n[Ivrq',tempV,']\n',
      'exten = s,1,Set(txt=',greeting_textV,')\n',
      'exten = s,n,Macro(SaveJourney,1,',ivrID,',,',tempV,')\n'
    );

    WHILE LENGTH(greeting_textV) > 0 DO
      SET tempV = SUBSTRING_INDEX(greeting_textV, '. ', 2);
      SET greeting_textV = SUBSTRING(greeting_textV, CHAR_LENGTH(tempV)+3);
      IF TRIM(tempV) != '' THEN
        SET result = concat(result,
          'exten = s,n,AGI(',scriptsDir,'/synthesis',synthesis_idV,'.sh,"',TRIM(tempV),'.")\n',
          'exten = s,n,Background(/usr/share/asterisk/sounds/cache/${sfile})\n'
        );
      END IF;
    END WHILE;

    SET result = concat(result,
      if(fallback_routeV!='',concat('exten = s,n,',fallback_routeV,'\n'),''),
      'exten = h,1,Macro(HangupScripts)\n'
    );

    SET i = i + 1;

  END WHILE;

  RETURN result;
END IF;




SELECT count(*) INTO hasSmsAutoReplyV
FROM commands WHERE type='CallSmsAutoReply' AND isActive = 1 AND conditions2 = ivrID;

SET result = concat('\n[Ivr',ivrID,']\n');


IF hasLocalCallV AND recognition_idV IS NULL THEN
  SET result = concat(result,'include=LocalCall\n');
END IF;


SET result = concat(result,
  'exten = s,1,Set(CHANNEL(musicclass)=Moh',ifnull(moh_idV,''),')\n',
  'exten = s,n,Verbose(1,"=====>>> IVR [',replace(nameV,',',' '),']<<<=====")\n',
  'exten = s,n,Set(__calllist_hangups=)\n',
  'exten = s,n,Set(MASTER_CHANNEL(calllist_hangups)=)\n',
  'exten = s,n,Set(CDR(dataset_id)=',dataset_idV,')\n',
  'exten = s,n,Set(ringFlag=',if(moh_idV is null,'r','m'),')\n',
  if(hasCallbackV    ,'exten = s,n,Macro(CallbackCall)\n',''),
  if(hasDisaV        ,'exten = s,n,Macro(DisaCall)\n',''),
  if(hasDisapasswordV,'exten = s,n,Macro(DisaPasswordCall)\n',''),
  if(hasSmsAutoReplyV,concat('exten = s,n,Macro(SendCallSmsAutoReply,',ivrID,',${CALLERID(num)})\n'),''),
  if(extensionV!='','exten = s,n,Answer\nexten = s,n,Wait(1)\n',''),
  if(resultV!='',concat('exten = s,n,Macro(SetCalllistResult,',resultV,')\n'),''),
  'exten = s,n,Set(ivr=)\n',
  if(biometryV=1,'exten = s,n,Macro(StartBiometry)\n',''));

IF hangupFileV != '' THEN
  SET result = concat(result,'exten = s,n,ExecIf( $[ $[ "${hscript}" != "0" ] & $[ ! ${REGEX("',hangupFileV,'" ${hangups})} ] ]?Set(hangups=${hangups} ',hangupFileV,') )\n');
END IF;

SET result = concat(result,
   if(relayVoiceV=1,concat('exten = s,n,ExecIf( $[ "${text}" != "" ]?AGI(',scriptsDir,'/recognize',ivrID,'.sh,"relayVoice:${text}","${data}") )\n'),''),
   if(relayVoiceV=1,concat('exten = s,n,ExecIf( $[ "${ivr}" != "" ]?Goto(Ivr${ivr},s,1) )\n'),'') );

  
IF greetingTypeV = 'SpitchSynthesis' AND synthesis_idV IS NOT NULL AND waitingV=0  THEN

  IF sayOrderTypeV!='RandomOne' THEN
    SET result = concat(result,
      'exten = s,n,Set(txt=',replace(greeting_textV,'|',' '),')\n',
	  'exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n');
  END IF;

  SET i = 0; SET voiceV = '';
  WHILE CHAR_LENGTH(greeting_textV) > 0 DO

    SET i = i + 1;
    SET tempV = SUBSTRING_INDEX(greeting_textV, '|', 1);
    SET greeting_textV = SUBSTRING(greeting_textV, CHAR_LENGTH(tempV)+2);

    SET voiceV = concat(voiceV,
      'exten = s,n,Macro(StartRec)\n',
      if(sayOrderTypeV='RandomOne',concat('exten = s,n,Set(txt=',replace(tempV,',',''),')\n'),''),
      if(sayOrderTypeV='RandomOne',concat('exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n'),''),
      'exten = s,n,MRCPSynth(<speak><prosody pitch=\'', pitch,'\' rate=\'', rate,'\' volume=\'',volume,'\' >"',REPLACE(tempV,'!','\\!'),'"</prosody></speak>,v=',voice,')\n',
      if(sayOrderTypeV='RandomOne','exten = s,n,Goto(continue)\n',''));

  END WHILE;

  IF sayOrderTypeV='RandomOne' AND i > 0 THEN
    SET result = concat(result,'exten = s,n,Goto(s${RAND(1,',i,')})\n');
  END IF;

  SET result = concat(result,voiceV);
  SET result = concat(result,'exten = s,n(continue),NoOp(Continue)\n');

ELSEIF greetingTypeV = 'VoiceFiles' THEN

  SET result = concat(result,
    'exten = s,n,Set(txt=', if(CHAR_LENGTH(voice_file_idV)>0, replace(nameV,',',' '),''),')\n',
    'exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n');

  SET i = 0; SET voiceV = '';
  WHILE CHAR_LENGTH(voice_file_idV) > 0 DO

    SET i = i + 1;
    SET pathV = SUBSTRING_INDEX(voice_file_idV,',', 1);
    SET voice_file_idV = SUBSTRING(voice_file_idV, CHAR_LENGTH(pathV)+2);

    SET tempV = '';
    SELECT uploads.path INTO tempV
    FROM phone_voice_files
    LEFT JOIN uploads ON uploads.id = phone_voice_files.upload_id
    WHERE phone_voice_files.id = pathV AND uploads.path IS NOT NULL;

    SET pathV = SUBSTRING_INDEX(tempV,'.',1);

    IF pathV != '' THEN
      SET voiceV = concat(voiceV,ifnull(concat('exten = s,n,Macro(StartRec)\n',
                                               'exten = s,n(v',i,'),Background(voice/',pathV,')\n'),''));
      IF sayOrderTypeV='RandomOne' THEN
        SET voiceV = concat(voiceV,'exten = s,n,Goto(continue)\n');
      END IF;
    END IF;

  END WHILE;

  IF sayOrderTypeV='RandomOne' AND i > 0 THEN
    SET result = concat(result,'exten = s,n,Goto(v${RAND(1,',i,')})\n');
  END IF;

  SET result = concat(result,voiceV);
  SET result = concat(result,'exten = s,n(continue),NoOp(Continue)\n');

ELSEIF greetingTypeV = 'LoadedFiles' THEN

  SET result = concat(result,
    'exten = s,n,Set(txt=', if(LENGTH(greeting_idV)>0, replace(nameV,',',' '),''),')\n',
    'exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n');

  SET i = 0; SET voiceV = '';
  WHILE LENGTH(greeting_idV) > 0 DO

    SET i = i + 1;
    SET tempV = SUBSTRING_INDEX(greeting_idV,',', 1);
    SET greeting_idV = SUBSTRING(greeting_idV, LENGTH(tempV)+2);
    SELECT ifnull(substring_index(path,'.',1),'') INTO pathV FROM uploads WHERE id=tempV;

    IF pathV != '' THEN
      SET voiceV = concat(voiceV,ifnull(concat('exten = s,n,Macro(StartRec)\n',
          'exten = s,n(l',i,'),Background(record/',pathV,')'),''));
      IF sayOrderTypeV='RandomOne' THEN
        SET voiceV = concat(voiceV,'exten = s,n,Goto(continue)');
      END IF;
    END IF;

  END WHILE;

  IF sayOrderTypeV='RandomOne' AND i > 0 THEN
    SET result = concat(result,'exten = s,n,Goto(l${RAND(1,',i,')})');
  END IF;

  SET result = concat(result,voiceV);
  SET result = concat(result,'exten = s,n(continue),NoOp(Continue)');

ELSEIF greetingTypeV = 'IntegrationSpitchSynthesis' AND synthesis_idV IS NOT NULL THEN

  SET result = concat(result,
    'exten = s,n,Set(txt=${REPLACE(message,|, )})\n',
    'exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n',
    'exten = s,n,GotoIf($[ "${audiofile}" != "" ]?skip)\n',
    'exten = s,n,GotoIf($[ "${message}" = "" ]?skip)\n',
    'exten = s,n(integration),Set(voice=${CUT(message,|,1)})\n',
    'exten = s,n,Set(message=${CUT(message,|,2-100)})\n',
	'exten = s,n,AGI(',scriptsDir,'/synthesis',synthesis_idV,'.sh,"${voice}")\n',
	'exten = s,n,Macro(StartRec)\n',
	'exten = s,n,Background(/usr/share/asterisk/sounds/cache/${sfile})\n',
	'exten = s,n,GotoIf($[ "${message}" != "" ]?integration)\n',
	'exten = s,n(skip),ExecIf($[ "${audiofile}" != "" ]?Playback(${audiofile}))\n',
    'exten = s,n,Set(audiofile=)\n');

END IF;

SET result = concat(result,
   if(relayVoiceV=1,'exten = s,n,ExecIf( $[ "${ivr}" != "" ]?Goto(Ivr${ivr},s,1) )\n',''),
   'exten = s,n,Set(text=)\n');

SET result = concat(result,
  'exten = s,n,ExecIf( $[ "${extension}" != "" ]?Set(__isManager=${extension}) )\n',
  'exten = s,n,ExecIf( $[ "${isManager}" != "" ]?Set(CDR(callee)=${isManager}) )\n',
  'exten = s,n,ExecIf( $[ "${isManager}" != "" ]?Set(CDR(isManager)=${isManager}) )\n',
  'exten = s,n,ExecIf( $[ "${dataset_id}" != "" ]?Set(CDR(dataset_id)=${dataset_id}) )\n',
  'exten = s,n,ExecIf( $[ "${extension}" != "" ]?Goto(',dialplanV,',${extension},1) )\n',
  'exten = s,n,Set(extension=)\n',
  'exten = s,n,ExecIf($[ "${error}" = "1" ]?Goto(i,1))\n');
IF recognition_idV IS NULL OR waitingV = 0 THEN

  SET result = concat(result,
    if(waitingV!=0,concat('exten = s,n,WaitExten(',waitingV,')\n'),''),
    'exten = s,n,Set(dt=${STRFTIME(${EPOCH},,%Y.%m.%d)})\n',
    'exten = s,n,Set(tm=${STRFTIME(${EPOCH},,%H.%M.%S)})\n',
    'exten = s,n,AGI(',scriptsDir,'/recognize',ivrID,'.sh,"","${data}","${CALLERID(num)}","${interactionID}")\n',
    'exten = s,n,Set(txt=)\n',
    'exten = s,n,ExecIf( $[ "${ivr}" != "" ]?Goto(Ivr${ivr},s,1) )\n');

ELSE

  IF waitingV != 0 THEN

    IF playBeepV THEN
      SET result = concat(result,'exten = s,n,Playback(beep)\n');
    END IF;

    IF hasLocalCallV THEN
       SET searchV = concat(
         'exten = s,n,ExecIf( $[ "${extension}" != "" ]?Macro(VoiceDictionary,',scriptsDir,'/synthesis',ifnull(synthesis_idV,''),'.sh',',${name},${extension}) )\n');
    END IF;

    IF recognitionTypeV = 'HTTP' THEN
      SET result = concat(result,
       'exten = s,n,Set(dt=${STRFTIME(${EPOCH},,%Y.%m.%d)})\n',
       'exten = s,n,Set(tm=${STRFTIME(${EPOCH},,%H.%M.%S)})\n',
       'exten = s,n,Set(wavfile=${dt}/${tm}-${UNIQUEID})\n',
       'exten = s,n,NoOp(RecognitionType ',recognitionTypeV,')\n',
       'exten = s,n,Record(/var/spool/asterisk/journeys/${wavfile}.wav,0,',waitingV,',q)\n',
       'exten = s,n,AGI(',scriptsDir,'/recognize',ivrID,'.sh,/var/spool/asterisk/journeys/${wavfile}.wav,"${data}","${CALLERID(num)}","${interactionID}","/var/spool/asterisk/journeys/${wavfile}.wav")\n',
       'exten = s,n,Set(txt=${text})\n',
       if(resultVarV!='',concat('exten = s,n,AGI(',integrationsDir,'/functions.sh,setVar,"${data}","',resultVarV,'","${text}")\n'),''),
       'exten = s,n,Macro(SaveJourney,0,',ivrID,',${wavfile},)\n',
       searchV,
       'exten = s,n,ExecIf( $[ "${ivr}" != "" ]?Goto(Ivr${ivr},s,1) )\n',
       'exten = s,n,ExecIf( $[ "${text}" != "" ]?',fallback_routeV,' )\n');
    END IF;

    IF recognitionTypeV = 'MRCP' THEN
    
    

      IF sayOrderTypeV!='RandomOne' THEN
        SET result = concat(result,
          'exten = s,n,Set(txt=',replace(greeting_textV,'|',' '),')\n',
    	  'exten = s,n,Macro(SaveJourney,1,',ivrID,',,)\n');
      END IF;

      SET i = 0; SET voiceV = '';
      IF CHAR_LENGTH(greeting_textV)=0 THEN
        SET greeting_textV = ' ';
      END IF;
      WHILE CHAR_LENGTH(greeting_textV) > 0 DO

        SET i = i + 1;
        SET tempV = SUBSTRING_INDEX(greeting_textV, '|', 1);
        SET greeting_textV = SUBSTRING(greeting_textV, CHAR_LENGTH(tempV)+2);

        SET voiceV = concat(voiceV,
         'exten = s,n(s',i,'),Set(dt=${STRFTIME(${EPOCH},,%Y.%m.%d)})\n',
         'exten = s,n,Set(tm=${STRFTIME(${EPOCH},,%H.%M.%S)})\n',
         'exten = s,n,Set(wavfile=${dt}/${tm}-${UNIQUEID})\n',
         'exten = s,n,NoOp(RecognitionType ',recognitionTypeV,')\n',
         'exten = s,n,MixMonitor(/var/spool/asterisk/journeys/${wavfile}.wav)\n',
         'exten = s,n,ExecIf( $[ "${mrcp}" != "" ]?MRCPRecog(${mrcp}):SynthAndRecog(',
         '<speak><prosody pitch=\'', pitch,'\' rate=\'', rate,'\' volume=\'',volume,'\' >"',REPLACE(tempV,'!','\\!'),'"</prosody></speak>',
                      ',',recognitionStringV,
                      '&t=',(waitingV*1000),
                      '&sct=',(waitingV*1000),
                      '&nit=',(waitingV*1000),
                      IF(interruptGreetingV,'&b=1','&b=0'),
                      '&vn=',voice,
                      '))\n',
  	     'exten = s,n,Set(mrcp=)\n',
         'exten = s,n,StopMixMonitor()\n',
         'exten = s,n,Set(RECOG_RESULT=${STRREPLACE(RECOG_RESULT,"&quote;","',"'",'")})\n',
         'exten = s,n,AGI(',scriptsDir,'/recognize',ivrID,'.sh,"${RECOG_RESULT}","${data}","${CALLERID(num)}","${interactionID}","/var/spool/asterisk/journeys/${wavfile}.wav")\n',
         'exten = s,n,Set(txt=${text})\n',
         if(resultVarV!='',concat('exten = s,n,AGI(',integrationsDir,'/functions.sh,setVar,"${data}","',resultVarV,'","${text}")\n'),''),
         'exten = s,n,Macro(SaveJourney,0,',ivrID,',${wavfile},)\n',
         searchV,
         'exten = s,n,ExecIf( $[ "${ivr}" != "" ]?Goto(Ivr${ivr},s,1) )\n',
         'exten = s,n,ExecIf( $[ "${text}" != "" ]?',fallback_routeV,' )\n');

      END WHILE;

      IF sayOrderTypeV='RandomOne' AND i > 0 THEN
        SET result = concat(result,'exten = s,n,Goto(s${RAND(1,',i,')})\n');
      END IF;

      SET result = concat(result,voiceV);
      SET result = concat(result,'exten = s,n(continue),NoOp(Continue)\n');

      
    

    END IF;

  END IF;

END IF;

IF timeout_routeV != '' THEN
  SET result = concat(result,'exten = s,n,',timeout_routeV,'\n');
  SET result = concat(result,'exten = t,1,',timeout_routeV,'\n');
END IF;

IF fallback_routeV != '' THEN
  SET result = concat(result,'exten = i,1,Set(error=)\n',
							 'exten = i,n,',fallback_routeV,'\n');
END IF;

SET result = concat(result,'exten = h,1,Macro(HangupScripts)\n');
SET result = concat(result,ifnull(ivr_routeV,''),'\n');

RETURN result;

END
;;
