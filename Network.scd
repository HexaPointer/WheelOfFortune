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
net.sendMsg('/sendID', id.asSymbol);

var nextID = 0; //Nächster User im Kreis


//ID vom nächsten kriegen um Kreis zu bilden
OSCdef(\circle, {|msg|
	//Die reinkommende Message besteht aus [s: cmd, i: recieverID, i: nextID]
	msg.postln; //for debugging

	(msg[1] == id).if({
		nextID = msg[2];
	});

}, '/circle');

OSCdef(\ {
	//DO THE THINGS
}, /)







)

///////////////////////////////////////////////

//Das hier wird dann der Master code

var net = NetAddr("127.0.0.1", 57150);
var idArray = Array.new;
var idCount = 0;


// Erstellt aus allen IDs einen Kreis
var generateCircle = {||

};

//Wird gecalled, wenn ein client seine ID schickt
OSCdef(\sendID, {|msg|
	//die reinkommende Message besteht aus [s: command, symbol: id]
	msg.postln; //for debugging

	switch (idCount,
		0, {
			idArray.add(msg[1]);
		} //TODO
	)
}, '/sendID');

//sendet jedem client die ID vom nächsten im Kreis
net.sendMsg('/circle', recieverID, ~recieverID, nextID, ~nextID);

)