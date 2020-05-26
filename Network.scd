//Das hier wird dann der Client code


/*
OSCjunction Setup:
- 'Start Receiving' auf 'WheelOfFortune Circle' (Port: NetAddr.langPort;)
- 'Start Sending' auf 'WheelOfFortune Circle' (Port: 57140)
*/
~id = 500000000.rand; //eigene ID
(
var net = NetAddr("127.0.0.1", 57140);
var nextID = 0; //Nächster User im Kreis


//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {arg msg;
	//Die reinkommende Message besteht aus [s: cmd, i: receiverID, i: nextID]
	msg.postln; //--------------DEBUG--------------

	(msg[1] == ~id).if({
		nextID = msg[2];
	});

}, '/circle');

//Wird aufgerufen von vorherigen, dier die aktuellen Parameter weiter schickt
OSCdef(\receiveParams, {arg msg;
	msg.postln;
	"This is the receiver function called".postln;
}, '/receiveParams');


~id.postln; //--------------DEBUG--------------
//Sendet eigene ID an Master
net.sendMsg('/sendID', ~id);





)

///////////////////////////////////////////////

//Das hier wird dann der Master code
(
var net = NetAddr("127.0.0.1", 57140);

var idList = List.new; //enthält alle IDs der clients

// Erstellt aus allen IDs einen Kreis
var generateCircle = {
	//sendet jedem client die ID vom nächsten im Kreis
	for (0,  idList.size - 1,
		{arg index;
			net.sendMsg('/circle', idList.at(index), idList.at((index + 1) % idList.size));
		}
	);

};
//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {arg msg;
	//die reinkommende Message besteht aus [s: command, i: id]
	msg.postln; //--------------DEBUG--------------

	(idList.collect.includes(msg[1])).if (
		{//die angekommene ID ist schon im User-Array!
			"ID nicht hinzugefügt! Entweder jemand ist reconnected oder hat die ID mehrfach oder nur nil gesendet!".postln;
		},
		{//die angekommene ID ist neu
			idList.add(msg[1]);
			"ID wurde aufgenommen.".postln;
			generateCircle.value;
			idList.postln; //--------------DEBUG--------------
		}
	)
}, '/sendID');




(//In diese section können commands die während des Stücks benutzt werden sollen, bspw. messages an alle clients

net.sendMsg('/receiveParams', "hopefully this worked") //--------------DEBUG--------------

)
)
