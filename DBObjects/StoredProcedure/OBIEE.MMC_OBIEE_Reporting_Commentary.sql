CREATE OR REPLACE PROCEDURE OBIEE.MMC_OBIEE_Reporting_Commentary(
        p_app_name IN VARCHAR2,
        p_app_sub_name IN VARCHAR2,
        p_commentary IN VARCHAR2,
        p_parameter IN VARCHAR2,
        p_user_name IN VARCHAR2,
        p_last_update_date IN VARCHAR2,
        ERRBUF OUT VARCHAR2,
        RETCODE OUT NUMBER)
       
IS
   v_commentary_id number;
   r_cnt int;

BEGIN
   v_commentary_id:=0;
   ERRBUF:='OK';
  begin
   select max(commentary_id),count(commentary_id) 
    into v_commentary_id, r_cnt 
    from OBIEE.REPORTING_COMMNETARY 
    where app_name=p_app_name
    and app_sub_name =p_app_sub_name
    and cast(parameter as varchar2(4000))=cast(p_parameter as varchar2(4000))
    group by commentary_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_commentary_id:=0;
   end; 
    DBMS_OUTPUT.PUT_LINE('Commentary_ID ' || v_commentary_id);
    
  BEGIN
    IF (v_commentary_id > 0)
     then 
      insert into OBIEE.REPORTING_COMMNETARY_Audit (commentary_id,app_name,app_sub_name,commentary,last_update_date,parameter,user_name,Status,Audit_Creation_Date)
      select commentary_id,app_name,app_sub_name,commentary,last_update_date,parameter,user_name,'H',sysdate
      from OBIEE.REPORTING_COMMNETARY 
      where 
      commentary_id=v_commentary_id;
      
      delete OBIEE.REPORTING_COMMNETARY  --- Added Comments By Ruby
      where commentary_id=v_commentary_id;  

      insert into  OBIEE.REPORTING_COMMNETARY values (REPORTING_COMMNETARY_seq.NEXTVAL,
      p_app_name,
      p_app_sub_name,
      p_commentary,
      p_parameter,
      p_user_name,
      sysdate,'A');
      RETCODE := 0;
      DBMS_OUTPUT.PUT_LINE('ERRBUF ' || ERRBUF);
      
     ELSE
      insert into  OBIEE.REPORTING_COMMNETARY values (REPORTING_COMMNETARY_seq.NEXTVAL,
      p_app_name,
      p_app_sub_name,
      p_commentary,
      p_parameter,
      p_user_name,
      sysdate,'A');
      RETCODE := 0;
      ERRBUF := 'OK';
      DBMS_OUTPUT.PUT_LINE('ERRBUF ' || ERRBUF);
    end IF; 
   commit; 
  END;

 EXCEPTION WHEN OTHERS THEN
    rollback;
    RETCODE := SQLCODE;
    ERRBUF := SQLERRM;
    DBMS_OUTPUT.PUT_LINE('ERROR IN Populating data for table MMCCUS.MMC_OBIEE_DIRECT_PSOFT_VW ' || RETCODE || '-' || ERRBUF);
END;
/
