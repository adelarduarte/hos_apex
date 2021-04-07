Declare
    l_response     clob;
Begin
    l_response := apex_web_service.make_rest_request(
      p_url => 'http://google.localhost:3000/users'
      , p_http_method => 'GET'
    );

   APEX_JSON.parse(l_response);
   
   dbms_output.put_line(l_response);

end;

