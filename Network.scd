//Das hier wird dann der Client code


/*
OSCjunction Setup:
- 'Start Receiving' auf 'RTT-Studie-Broadcast' (Port:*/ NetAddr.langPort;/*)
- 'Start Sending' auf 'RTT-Studie-Rückkanal' (Port: 57140)
*/

(
var net = NetAddr("127.0.0.1", 57140);
var id = 500000000.rand;

//Sendet eigene ID an Master
net.sendMsg('/sendID', id);

var nextID = 0; //Nächster User im Kreis


//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {|msg|
	//Die reinkommende Message besteht aus [s: cmd, i: recieverID, i: nextID]
	msg.postln; //for debugging

	(msg[1] == id).if({
		nextID = msg[2];
	});

}, '/circle');

//Wird aufgerufen von vorherigen, dier die aktuellen Parameter weiter schickt
OSCdef(\recieveParams {
	//
}, '/recieveParams')







)

///////////////////////////////////////////////

//Das hier wird dann der Master code
(
var net = NetAddr("127.0.0.1", 57150);

var idArray = Array.new; //enthält alle IDs der clients

/* Enthält die IDs, an die die IDs aus idArray senden:
*  bspw. idArray[4] sendet and nextArray[4]
*  im Normalfall sendet idArray[n] immer an idArray[n+1]
*/
var nextArray = Array.new;

var idCount = 0;
~recieverID = 0;
~nextID =;


// Erstellt aus allen IDs einen Kreis
var generateCircle = {
	switch (idArray.size,
		0, {
			"Etwas ist schiefgelaufen, generateCircle wurde ohne IDs im Array aufgerufen!".postln;
		},
		1, {//Nur eine ID registriert
			//nextArray = idArray; //Client sendet an sich selbst?
		},
		2, {
			nextArray = idArray.rotate(-1); //Weglassen für idArray.wrapAt[idArray.size+1]?
		},
	)
};

var sendCircle = {
	//sendet jedem client die ID vom nächsten im Kreis
	for (0, idArray.size,
		{

		}
	);
	net.sendMsg('/circle', ~recieverID, ~nextID);
};
//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {|msg|
	//die reinkommende Message besteht aus [s: command, symbol: id]
	msg.postln; //for debugging

	(idArray.collect.includes(msg[1]) || msg[1].isNil).if (
		{//die angekommene ID ist schon im User-Array!
			"ID nicht hinzugefügt! Entweder jemand ist reconnected oder hat die ID mehrfach oder nur nil gesendet!".postln;
		},
		{//die angekommene ID ist neu
			idArray.add(msg[1]);
			"ID wurde aufgenommen.".postln;
			generateCircle;
		}
	)
}, '/sendID');




)