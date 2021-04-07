
sendgrid api: oNfxpAdLRUyPQl9y3XPErw

smtp: smtp.sendgrid.net
porta: 25

usuario: apikey
senha :{api}

usar ssl/tls: Não


apex_mail.send (
	p_to => 'adduarte@icloud.com',
	p_from => 'suporte@careup.com.br',
	p_body => 'Teste de envio de email',
	p_subj => 'Teste de email'
);

apex_mail.push_queue;



