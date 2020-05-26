//Das hier wird dann der Client code


/*
OSCjunction Setup:
- 'Start Receiving' auf 'WheelOfFortune Broadcast' (Port: NetAddr.langPort;)
- 'Start Receiving' auf 'WheelOfFortune Circle' (Port: NetAddr.langPort;)
- 'Start Sending' auf 'WheelOfFortune Circle' (Port: 57140)
*/

(
var net = NetAddr("127.0.0.1", 57140);
var id = 500000000.rand; //eigene ID
var nextID = 0; //Nächster User im Kreis


//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {arg msg;
	//Die reinkommende Message besteht aus [s: cmd, i: receiverID, i: nextID]
	msg.postln; //--------------DEBUG--------------

	(msg[1] == id).if({
		nextID = msg[2];
	});

}, '/circle');

//Wird aufgerufen von vorherigen, dier die aktuellen Parameter weiter schickt
OSCdef(\receiveParams, {arg msg;
	msg.postln;
	"This is the receiver function called".postln;
}, '/receiveParams');


id.postln; //--------------DEBUG--------------
//Sendet eigene ID an Master
net.sendMsg('/sendID', id);





)

///////////////////////////////////////////////

//Das hier wird dann der Master code
(
var net = NetAddr("127.0.0.1", 57140);

var idArray = Array.new; //enthält alle IDs der clients

// Erstellt aus allen IDs einen Kreis
var generateCircle = {

	//sendet jedem client die ID vom nächsten im Kreis
	for (0, idArray.size,
		{arg index;
			net.sendMsg('/circle', idArray.at(index), idArray.wrapAt(index + 1));
		}
	);

};
//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {|msg|
	//die reinkommende Message besteht aus [s: command, symbol: id]
	msg.postln; //--------------DEBUG--------------

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




(//In diese section können commands die während des Stücks benutzt werden sollen, bspw. messages an alle clients

net.sendMsg('/receiver', "hopefully this worked") //--------------DEBUG--------------

)
)
