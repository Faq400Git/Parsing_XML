000101191101       //-----------------------------------------
000102191101       // F4XML01: SQLRPGLE Source
000103191101       //   We are trying to parse and XML stored
000104191101       //   in our IFS, and extract data from
000105191101       //   different levels and  different namespaces
000106191101       //   through XMLTABLE and XMLPARSE SQL Function
000107191101       //
000108191101       //   Pay attention to GET_XML_FILE to read an xml
000109191101       //   stored in the IFS
000110191101       //
000111191101       //   Rev. 4
000112191101       // ------------------------------------------------
000113191101       ctl-opt DFTACTGRP(*NO);
000114191101
000115191029
000116191101
000117191029
000118191031       dcl-ds dsresult qualified dim(999);
000119191029         totalrecords packed(9:0);
000120191029         pagesize packed(9:0);
000121191029         totalpages packed(9:0);
000122191029         pageindex packed(9:0);
000123191029         searchid varchar(50);
000124191029         displayname varchar(50);
000125191029         internalid varchar(50);
000126191029         itemid varchar(50);
000127191029         saleunit varchar(50);
000128191029         type varchar(50);
000129191029         weight varchar(50);
000130191029       end-ds;
000131191029
000132191029
000133191029
000134191029
000135191029       dcl-s  risposta char(10);
000136191031
000137191031       dcl-s  RowsFetched int(5);
000138191031       dcl-s  i           int(5);
000139191031
000140191029
000141191101       // Set COMMIT to read XML file from IFS
000142191101       exec sql SET OPTION COMMIT=*CHG;
000196191029
000197191101       // Set CCSID for some HTTP Functions (65535 is no good!)
000198191029       exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(280)');
000199191031
000209191029
000210191101       // Get my XML file from IFS and parse it with  XMLTABLE
000211191101       // and XMLPARSE SQL Functions
000214191031       exec sql
000215191031        declare wscursor cursor for
000216191031        select *
000217191029        FROM
000218191029        XMLTABLE(
000219191029        xmlnamespaces
000220191029        (default 'urn:core_2018_1.platform.webservices.netsuite.com',
000221191029         'http://schemas.xmlsoap.org/soap/envelope/' AS "soap",
000222191029         'urn:accounting_2018_1.lists.webservices.netsuite.com' as "listact",
000223191029         'urn:common_2018_1.platform.webservices.netsuite.com' as "platf"
000224191029            ),
000225191029          '$doc/soap:Envelope/soap:Body/+
000226191029          *:searchResponse/searchResult/+
000227191029          *:searchRowList/searchRow[*]'
000228191029       PASSING
000229191101       xmlparse(document GET_XML_FILE('/tmp/NetSuite XML SOAP Response.xml'))
000231191029       as "doc"
000232191029       columns
000233191029       totalRecords decimal(9, 0) path '../../totalRecords',
000234191029       pageSize decimal(9, 0) path '../../pageSize',
000235191029       totalPages decimal(9, 0) path '../../totalPages',
000236191029       pageIndex decimal(9, 0) path '../../pageIndex',
000237191029       searchId varchar(50) path '../../searchId',
000238191029       displayName varchar(50) path '*:basic/*:displayName/searchValue',
000239191029       internalId varchar(50)
000240191029         path '*:basic/*:internalId/searchValue/@internalId',
000241191029       itemId varchar(50) path '*:basic/*:itemId/searchValue',
000242191029       saleUnit varchar(50) path '*:basic/*:saleUnit/searchValue/@internalId',
000243191029       type varchar(50) path '*:basic/*:type/searchValue',
000244191029       weight varchar(50) path '*:basic/*:weight/searchValue'
000245191031       ) as a;
000246191031
000247191031       exec sql open wscursor;
000248191031
000249191031       exec sql
000250191031          fetch wscursor for 999 rows into :dsresult;
000251191031
000252191031       exec sql GET DIAGNOSTICS :RowsFetched = ROW_COUNT ;
000255191029
000256191101       // Return to my current job CCSID
000257191029       exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(*USRPRF)');
000258191029
000259191031       dsply 'Risultato:';
000260191031       for i=1 to RowsFetched;
000261191101          dsply 'Row :';
000262191031          dsply i;
000263191031          dsply '- displayname:';
000264191031          dsply dsresult(i).displayname;
000265191031          dsply '- internalid:';
000266191031          dsply dsresult(i).internalid;
000267191031          dsply '- itemid:';
000268191031          dsply dsresult(i).itemid;
000269191031          dsply '- weight:';
000270191031          dsply dsresult(i).weight;
000271191031       endfor;
000272191101       dsply 'End' '' risposta;
000273191031
000274191029
000275191029       *inlr=*on;
000276191029
000277191029
