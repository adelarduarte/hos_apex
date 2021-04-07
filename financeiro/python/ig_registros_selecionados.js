// Usar grade interativa, com o seguinte código em javascript no botão de enviar cobrança:

// ***** É necessário identificar a IG, como no exemplo abaixo (ig_cobrancas)


var record, id_cobranca;

//Pegar a grid identificada
var ig$     = apex.region("ig_cobrancas").widget();
 
//Pegar o model da grid
var grid    = ig$.interactiveGrid("getViews","grid");
var model   = ig$.interactiveGrid("getViews","grid").model;
 
//Carregar os registros selecionados
var selectedRecords = apex.region("ig_cobrancas").widget().interactiveGrid("getViews","grid").view$.grid("getSelectedRecords");
 
//Iterar nos registros, mudando os valores desejados
for (idx=0; idx < selectedRecords.length; idx++) {
    //Pegar o registro selecionado
    record = model.getRecord(selectedRecords[idx][0]);
 
    id_cobranca = model.getValue(record, "CODIGO_EXTERNO");
 	
 	// Atualizar o registro
    model.setValue(record, "CODIGO_EXTERNO", "Emitir_Cobranca");
 }

// Submeter a IG
apex.submit("ig_cobrancas");


// Ao submeter a página, chamar uma procedure
// que trate os registros marcados...

// Nesse caso em especial, os registros marcados serão 
// tratados pelo serviço em python.

