// number of stepping rotors
var NUM_ROTORS = 3;

// rotor wirings
// rotors I-VIII taken from wikipedia
var wirings = [ "EKMFLGDQVZNTOWYHXUSPAIBRCJ",
                "AJDKSIRUXBLHWTMCQGZNPYFVOE",
                "BDFHJLCPRTXVZNYEIWGAKMUSQO",
                "ESOVPZJAYQUIRHXLNFTGKDCMWB",
                "VZBRGITYUPSDNHLXAWMJQOFECK",
                "JPGVOUMFYQBENHZRDKASXLICTW",
                "NZJHGRCXMYSWBOUFAIVLPEKQDT",
                "FKQHTLXOCBJSPDZRAMEWNIUYGV" ];

// reflectors A,B,C from wikipedia
var reflectors = [ "EJMZALYXVBWFCRQUONTSPIKHGD",
                   "YRUHQSLDPXNGOKMIEBFZCWVJAT",
                   "FVPJIAOYEDRZXWGCTKUQSBNMHL" ];

// rotor notches
var notches = [ [16],
                [4],
                [0]  ]; //third notch not used

// converts "EKMF..." into [4, 10, 12, 5, ...]
var charStringToIntArray = function ( charString ) {
    var intArray = [];
    for (var i=0; i<charString.length; i++) {
        intArray.push( 
            charString.charCodeAt(i) - "A".charCodeAt() );
    }
    return intArray;
};

// converts [4, 10, 12, 5] into "EKMF"
var intArrayToCharString = function ( intArray ) {
    var chars = [];
    for (var i=0; i<intArray.length; i++) {
        chars.push( intToChar( intArray[i] ) );
    }
    return chars.join("");
};

// converts 4 into E
var intToChar = function ( intIn ) {
    return String.fromCharCode(
                intIn + "A".charCodeAt() );
};

// converts [3,2,4,1] to [4,2,1,3]
var makeInverseRotor = function ( rotor ) {
    var irotor = []
    for (var i=0; i<rotor.length; i++) {
        irotor.push( rotor.indexOf(i) );
    }
    return irotor;
};

// select rotors and make inverses
// (I'm just taking I,II,III for now)
var rotors  = [];
var irotors = [];
for (var i=0; i<NUM_ROTORS; i++) {
    rotors.push( charStringToIntArray(wirings[i]) );
    irotors.push( makeInverseRotor( rotors[i] ) );
}

// select the reflector
// (here, I want just B for now)
var reflector = charStringToIntArray(reflectors[1]);
var reflPos = 0;

// initial rotor positions
var positions = [0, 0, 0];

// compute next rotor positions
// first, set first rotor to always step,
// then go through middle rotors, which step when
// either they or the previous rotor are at a notch,
// then do the last rotor, which only steps when the
// previous rotor is at a notch.
var rotorStep = function (rotors, positions, notches) {
    var max = rotors.length-1;

    // first rotor always steps
    var stepB = [1];

    // now do the middle rotors
    for (var r=1; r<max; r++) {
        stepB.push(0);
        // step if previous rotor is at a notch
        if(notches[r-1].indexOf( positions[r-1] ) != -1){
            stepB[r] = 1;
        }

        // step if this rotor is at a notch
        // ("double stepping")
        if(notches[r].indexOf( positions[r] ) != -1){
            stepB[r] = 1;
        }
    }

    // now do the last rotor
    // step is previous rotor is at a notch
    stepB.push(0);
    if(notches[max-1].indexOf( positions[max-1] ) != -1){
        stepB[max] = 1;
    }

    console.log(stepB);
    // do the actual stepping
    for (var r=0; r<rotors.length; r++) {
        if(stepB[r]) { 
            positions[r] = (positions[r] + 1) % 26;
        }
    }

    return positions;
};

// send char through the device
// "letter" is actually an integer
var encryptLetter = function (letter, rotors, reflector, positions, reflPos) {
    var x = letter;

    console.log("before 0th rotor, x is %s",intToChar(x));
    // go through all rotors
    for(var r=0; r<rotors.length; r++) {
        x = (rotors[r][(x + positions[r]) % 26] + 26 - positions[r]) % 26;
        console.log("after forward rotor %d, x is %s",r,
                        intToChar(x) );
    }

    // go through reflector
    x = reflector[(x + reflPos) % 26];
    console.log("after reflector, x is %s",intToChar(x));

    // inverse through the rotors
    for(var r=rotors.length-1; r>=0; r--) {
        x = (rotors[r].indexOf( (x + positions[r]) % 26 ) - 
                positions[r] + 26) % 26;
        console.log("after reverse rotor %d, x is %s",r,
                        intToChar(x) );
    }

    console.log("---");
    return x;
};

// take a plaintext string, return cipher string
var encryptString = function (string) {
    // first get intArray from string
    var letters = charStringToIntArray(string);
    // encrypt each letter
    var ciphers = [];
    for(var i=0; i<letters.length; i++) {
        rotorStep(rotors,positions,notches);
        ciphers.push( encryptLetter(letters[i], 
            rotors, reflector, positions, reflPos));
    }
    return intArrayToCharString(ciphers);
};
