(function() {

  'use strict';

  var ENTER_KEY = 13;
  var newTodoDom = document.getElementById('new-todo');
  var syncDom = document.getElementById('sync-wrapper');

  // EDITING STARTS HERE (you dont need to edit anything above this line)
  
  var db = new PouchDB('todosList');

  var remoteCouch = 'http://localhost:4984/todolite';

  db.changes({
    since: 'now',
    live: true
  }).on('change', showTodos);


  // We have to create a new todo document and enter it in the database

    function addTodo(text) {

        var todo = {
            _id: "user1."+new Date().getMilliseconds().toString(),
            name: text,
            type: "task-list",
            owner:"user1"
        };
    db.put(todo).then(function(result){
      console.log("Everything is A-OK")
      console.log(result); 
    }).catch(function(err){
      console.log("Error while saving the doc");
      console.log(err);
    });
    }


  // Show the current list of todos by reading them from the database
 function showTodos() {

    db.allDocs({
        include_docs: true,
        descending: true
    }).then(function (doc){
        console.log("showTodos: "+doc.rows);
        console.log("showTodos: "+doc);
        redrawTodosUI(doc.rows);

    }).catch(function (err){
      console.log(err);
    });
  }


  function mostrarDocumentosAsociadosAPaciente(todo){
        //console.log("mostrarDocumentosAsociadosAPaciente -> todo._id: " + todo._id);
        var idTodo = todo._id;

      db.get("motivo."+idTodo).then(function(doc){

          //console.log("mostrarDocumentosAsociadosAPaciente -> doc.rows: "+doc);
          //mostrarPacienteYDatos(doc);

      }).catch(function(err){
          //console.log("mostrarDocumentosAsociadosAPaciente: ERROR PEPINO");
      });
  }

  function mostrarPacienteYDatos(docTodo){

      var listaHTML = document.getElementById('todo-list');
      listaHTML.innerHTML = '';

      var nombrePacienteHTML = document.getElementById('nombre-Paciente');

      //HTML DE CONSTANTES VITALES
      var temperaturaHTML = document.getElementById('temperatura-list');
      temperaturaHTML.innerHTML = '';

      var pulsoHTML = document.getElementById('pulso-list');
      pulsoHTML.innerHTML = '';

      var pulsiosimetriaHTML = document.getElementById('pulsiosimetria-list');
      pulsiosimetriaHTML.innerHTML = '';

      var tensionHTML = document.getElementById('tension-list');
      tensionHTML.innerHTML = '';

      //HTML DE MEDICACIÓN Y ALERGIAS
      var medicacionAlergiasTitle = document.getElementById('medicacion-alergias-title');
      medicacionAlergiasTitle.innerHTML = '';

      var medicacionTitleHTML = document.getElementById('medicacion-title');
      medicacionTitleHTML.innerHTML = '';

      var medicacionTextHTML = document.getElementById('medicacion-text');
      medicacionTextHTML.innerHTML = '';

      var alergiasTitleHTML = document.getElementById('alergias-title');
      alergiasTitleHTML.innerHTML = '';

      var alergiasTextHTML = document.getElementById('alergias-text');
      alergiasTextHTML.innerHTML = '';


      //HTML DE HABITOS TOXICOS:
      var habitosToxicosTitle = document.getElementById('habitos-toxicos-title');
      habitosToxicosTitle.innerHTML = '';

      var tabacoTitleHTML = document.getElementById('tabaco-title');
      tabacoTitleHTML.innerHTML = '';

      var tabacoTextHTML = document.getElementById('tabaco-text');
      tabacoTextHTML.innerHTML = '';

      var alcoholTitleHTML = document.getElementById('alcohol-title');
      alcoholTitleHTML.innerHTML = '';

      var alcoholTextHTML = document.getElementById('alcohol-text');
      alcoholTextHTML.innerHTML = '';

      var alcoholDescriptionTextHTML = document.getElementById('alcohol-description-text');
      alcoholDescriptionTextHTML.innerHTML = '';

      var edadTitleHTML = document.getElementById('edad-title');
      edadTitleHTML.innerHTML = '';

      var edadTextHTML = document.getElementById('edad-text');
      edadTextHTML.innerHTML = '';

      //HTML DE PLAN TERAPEUTICO:
      var planTitleHTML = document.getElementById('plan-title');
      planTitleHTML.innerHTML = '';

      var planTextHTML = document.getElementById('plan-text');
      planTextHTML.innerHTML = '';


      var idMotivo = docTodo._id;
      var longitudIdMotivo = idMotivo.length;
      var idDocPaciente = idMotivo.substring(7, longitudIdMotivo);

      // Poner como título el nombre del paciente
      db.get(idDocPaciente).then(function(doc){
          nombrePacienteHTML.innerHTML = doc.name;
      }).catch(function(err){
          console.log("mostrarPacienteYDatos ->Error actualizando título");
      });

      // Conseguir el documento de Constantes Vitales
      var idConstantesVitales = "exploracion.constantesVitales."+idDocPaciente;
      var docConstantesVitales = null;
      console.log("TONI -> idConstantesVitales: "+idConstantesVitales);
      db.get(idConstantesVitales).then(function(doc){
          docConstantesVitales = doc;
          console.log("TONI -> Documento de constantesVitales localizado: "+ doc._id);

          var constantesVitalesTitle = document.getElementById('constantes-vitales-title');
          constantesVitalesTitle.appendChild(document.createTextNode("Constantes Vitales"));

          temperaturaHTML.appendChild(document.createTextNode("Temperatura: "+docConstantesVitales.Temperatura));
          pulsoHTML.appendChild(document.createTextNode("Pulso: "+docConstantesVitales.Pulso));
          pulsiosimetriaHTML.appendChild(document.createTextNode("Pulsiosimetria: "+docConstantesVitales.Pulsiosimetria));
          tensionHTML.appendChild(document.createTextNode("Tensión: "+docConstantesVitales.Tension_Sistolica));

      }).catch(function(err){
          console.log("mostrarPacienteYDatos ->Error buscando ConstantesVitales");
      });

      // Conseguir el documento de Medicacion y alergias
      var idMedicacionYAlergias = "exploracion.medicacionYAlergias."+idDocPaciente;
      var docMedicacionYAlergias = null;
      console.log("TONI -> idMedicacionYAlergias: "+idMedicacionYAlergias);
      db.get(idMedicacionYAlergias).then(function(doc){
          docMedicacionYAlergias = doc;
          console.log("TONI -> Documento de medicacion localizado: "+ doc._id);

          var medicacionYAlergiasTitle = document.getElementById('medicacion-alergias-title');
          medicacionYAlergiasTitle.appendChild(document.createTextNode("Medicación y Alergias"));

          medicacionTitleHTML.appendChild(document.createTextNode("Medicación: "));
          medicacionTextHTML.appendChild(document.createTextNode(docMedicacionYAlergias.Medicacion));

          alergiasTitleHTML.appendChild(document.createTextNode("Alergias: "));
          alergiasTextHTML.appendChild(document.createTextNode(docMedicacionYAlergias.Alergias));

      }).catch(function(err){
          console.log("mostrarPacienteYDatos ->Error buscando Medicación y alergias");
      });



      // Conseguir el documento de Habitos Toxicos
      var idHabitosToxicos = "exploracion.HabitosToxicos."+idDocPaciente;
      var docHabitosToxicos = null;
      console.log("TONI -> idHabitosToxicos: "+idHabitosToxicos);
      db.get(idHabitosToxicos).then(function(doc){
          docHabitosToxicos = doc;
          console.log("TONI -> Documento de habitos Toxicos localizado: "+ doc._id);

          var habitosToxicosTitle = document.getElementById('habitos-toxicos-title');
          habitosToxicosTitle.appendChild(document.createTextNode("Hábitos Tóxicos"));

          tabacoTitleHTML.appendChild(document.createTextNode("Consumo de tabaco: "));
          tabacoTextHTML.appendChild(document.createTextNode(docHabitosToxicos.Fumador));

          alcoholTitleHTML.appendChild(document.createTextNode("Consumo de alcohol: "));
          alcoholTextHTML.appendChild(document.createTextNode(docHabitosToxicos.Alcohol));
          alcoholDescriptionTextHTML.appendChild(document.createTextNode(docHabitosToxicos.Descripcion_consumo_alcohol));

          edadTitleHTML.appendChild(document.createTextNode("Edad: "));
          edadTextHTML.appendChild(document.createTextNode(docHabitosToxicos.Edad));

      }).catch(function(err){
          console.log("mostrarPacienteYDatos ->Error buscando Medicación y alergias");
      });

      //Conseguir el documento del plan terapeutico
      var idPlan = "plan."+idDocPaciente;
      var docPlan = null;
      console.log("TONI -> idHabitosToxicos: "+idHabitosToxicos);
      db.get(idPlan).then(function(doc){
          docPlan = doc;
          console.log("TONI -> Documento de habitos Toxicos localizado: "+ doc._id);

          var planTitle = document.getElementById('plan-title');
          planTitle.appendChild(document.createTextNode("Plan Terapéutico: "));
          var planText = document.getElementById('plan-text');
          planText.appendChild(document.createTextNode(docPlan.Plan_terapeutico));


      }).catch(function(err){
          console.log("mostrarPacienteYDatos ->Error buscando Medicación y alergias");
      });




      console.log("mostrarPacienteYDatos -> docTodo: "+docTodo);
      console.log("mostrarPacienteYDatos -> docTodo._id: "+docTodo._id);

      console.log("antes de listaHtml");

      var label = document.createElement('label');

      console.log("mostrarPacienteYDatos: " + docTodo.Motivo_de_la_consulta);

      var motivoConsultaTitle = document.getElementById('motivo-consulta-title');
      motivoConsultaTitle.appendChild(document.createTextNode("Informe Completo:"));
      listaHTML.appendChild(document.createTextNode(docTodo.Motivo_de_la_consulta));

      console.log("mostrarPacienteYDatos: Constantes Vitales: " + docConstantesVitales);
      //listaHTML.appendChild(document.createTextNode(docConstantesVitales.Temperatura));

  }

  function checkboxChanged(todo, event) {
    todo.completed = event.target.checked;
    console.log(todo);
    db.put(todo);
  }

  // User pressed the delete button for a todo, delete it
  function deleteButtonPressed(todo) {
      var motivoAsociado = db.get("motivo."+todo._id);
      db.remove(todo);
      db.remove(motivoAsociado);

  }

  // TONI: El usuario a pulsado el botón de mostrar datos del paciente Motivo de la consulta
    /*
  function constantesButtonPressed(todo){
      db.get("exploracion.constantesVitales."+todo._id).then(function(doc){
            var constantesVitalesAEnviar = doc;
            console.log("constantesVitales: " + doc._id);
            mostrarPacienteYDatos(todoAEnviar);

      }).catch(function(err){
          //console.log("dataButtonPressed: Documento motivo no encontrado, pero en realidad tiene _id:" + todo._id);
      });
  }*/

    // TONI: El usuario a pulsado el botón de constantesVitales
    function dataButtonPressed(todo){
        db.get("motivo."+todo._id).then(function(doc){
            var todoAEnviar = doc;
            console.log("dataButtonPressed: " + doc._id);
            mostrarPacienteYDatos(todoAEnviar);

        }).catch(function(err){
            //console.log("dataButtonPressed: Documento motivo no encontrado, pero en realidad tiene _id:" + todo._id);
        });
    }



  // The input box when editing a todo has blurred, we should save
  // the new title or delete the todo if the title is empty
  function todoBlurred(todo, event) {
    var trimmedText = event.target.value.trim();
    if (!trimmedText) {
      db.remove(todo);
    } else {
      todo.title = trimmedText;
      db.put(todo);
    } 
  }
  
  // Initialise a sync with the remote server
  function sync() {
    syncDom.setAttribute('data-sync-state', 'syncing');
    var opts = {live: true};
    //db.sync(remoteCouch, opts, syncError);


      db.replicate.to(remoteCouch, opts, syncError);
      console.log("replicate to");
      db.replicate.from(remoteCouch, opts, syncError);
      console.log("replicate from");

 
  }

  // EDITING STARTS HERE (you dont need to edit anything below this line)

  // There was some form or error syncing
  function syncError() {
    syncDom.setAttribute('data-sync-state', 'error');
  }

  // User has double clicked a todo, display an input so they can edit the title
  function todoDblClicked(todo) {
    var div = document.getElementById('li_' + todo._id);
    var inputEditTodo = document.getElementById('input_' + todo._id);
    div.className = 'editing';
    inputEditTodo.focus();
  }

  // If they press enter while editing an entry, blur it to trigger save
  // (or delete)
  function todoKeyPressed(todo, event) {
    if (event.keyCode === ENTER_KEY) {
      var inputEditTodo = document.getElementById('input_' + todo._id);
      inputEditTodo.blur();
    }
  }

  // Given an object representing a todo, this will create a list item
  // to display it.
  function createTodoListItem(todo) {

        /* TONI - Checkbox:
        var checkbox = document.createElement('input');
        checkbox.className = 'toggle';
        checkbox.type = 'checkbox';
        checkbox.addEventListener('change', checkboxChanged.bind(this, todo));
        */

        /* TONI: La siguiente linea describe el cajetin en el que se muestra el pacient
         * por lo que cualquier label.appendChild que le hagas lo concatenará dentro del
         * cajon.
         */
        var label = document.createElement('label');
        console.log("TONI -> Todo.name: "+todo.name)
        label.appendChild(document.createTextNode(todo.name))
        //label.appendChild(document.createTextNode(todo._id))
        label.addEventListener('dblclick', todoDblClicked.bind(this, todo));

        /* TONI: A partir de aqui se define el comportamiento del boton de borrado
         * esencial para cuando quiera borrar no solo los pacientes sino también sus motivos y eso
         */
        var deleteLink = document.createElement('button');
        deleteLink.className = 'destroy';
        deleteLink.addEventListener( 'click', deleteButtonPressed.bind(this, todo));

        /* TONI: Creación del botón de mostrar Motivo de la consulta en la db
         */

        var dataLink = document.createElement('button');
        dataLink.className = 'redirect';
        console.log("todo enviado al botón data: "+todo._id);
        dataLink.addEventListener( 'click', dataButtonPressed.bind(this, todo));


        /* TONI: El siguiene codigo te define la concatenación de label, boton de borrar y de checkbox
         * al final lo que hace es añadirlo en un div y poner el contenido a continuación ¡easy!
         */
        var divDisplay = document.createElement('div');
        divDisplay.className = 'view';
        // TONI - Checkbox: divDisplay.appendChild(checkbox);
        divDisplay.appendChild(label);
        divDisplay.appendChild(deleteLink);
        divDisplay.appendChild(dataLink);


        /* TONI: Codigo para definir el input para editar el nombre del paciente introducido
         *
         */
        var inputEditTodo = document.createElement('input');
        inputEditTodo.id = 'input_' + todo._id;
        inputEditTodo.className = 'edit';
        inputEditTodo.value = todo.name;
        inputEditTodo.addEventListener('keypress', todoKeyPressed.bind(this, todo));
        inputEditTodo.addEventListener('blur', todoBlurred.bind(this, todo));

      /* TONI: CLAVE!
       * Este codigo te va a definir toda la vista, es decir, va a crear una lista que sea la concatenación
       * de todos los elementos anteriores, divs + input para que así resulte plenamente intuitiva.
       */
        var li = document.createElement('li');
        li.id = 'li_' + todo._id;
        li.appendChild(divDisplay);
        li.appendChild(inputEditTodo);



        /* TONI: Codigo para variar la propiedad de completado dentro del documento.
        if (todo.completed) {
          li.className += 'complete';
          //TONI - Checkbox: checkbox.checked = true;
        }
        */

        return li;
  }

  //Equivalente a: mostrarPacienteYDatos
  function redrawTodosUI(todos) {
    var listaHTML = document.getElementById('todo-list');
    listaHTML.innerHTML = '';
    todos.forEach(function(todo) {
        console.log("TONI -> redrawTodosUI todo.doc: "+todo.doc);
        console.log("TONI -> redrawTodosUI todo.doc._id: "+todo.doc._id);

        var string_Id = todo.doc._id;
        var subString_id = string_Id.substring(0, 5);
        console.log("TONI -> subString._id: "+subString_id);

        if(subString_id == "user1"){
            console.log("TONI -> subString._id: "+subString_id);
            listaHTML.appendChild(createTodoListItem(todo.doc));
        }

    });
  }

  function newTodoKeyPressHandler( event ) {
    if (event.keyCode === ENTER_KEY) {
      addTodo(newTodoDom.value);
      newTodoDom.value = '';
    }
  }

  function addEventListeners() {
    newTodoDom.addEventListener('keypress', newTodoKeyPressHandler, false);
  }

  addEventListeners();
  showTodos();

  if(remoteCouch){
    sync();
  }

})();
