CREATE OR REPLACE FUNCTION CAREUP."MY_HASH" (  
    p_username IN VARCHAR2,  
    p_password IN VARCHAR2)  
  RETURN VARCHAR2  
IS  
  l_password VARCHAR2(2000);  
  l_salt     VARCHAR2(2000) := 'ISYmHMtXrjFmT5nEZUvEU7LB5jrV3i';BEGIN  

apex_debug.message('username is: ' || p_username || ' and password is '   || p_password);  


  l_password := utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5(input_string => p_password || SUBSTR(l_salt,10,13) || p_username || SUBSTR(l_salt, 4,10)));  RETURN l_password;  
END;
