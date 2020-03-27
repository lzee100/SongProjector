
class ContractNL {
    static getFree () {
        return {
            id: 1,
            name: "Gratis",
            features: [ 
                {
                    position: 0,
                    content: "• Maximaal 10 eigen nummers opslaan"
                }, 
                {
                    position: 1,
                    content: "• Onbeperkt aantal eigen thema's opslaan"
                },
                {
                    position: 2,
                    content: "• Onbeperkt bijbelteksten dia's genereren en opslaan"
                },
                {
                    position: 3,
                    content: "• Maximaal 1 apparaat"
                }
            ],
            button: "Gratis"
        }
    }

    static getBeam () {
        return {
            id: 2,
            name: "Beam",
            features: [
                {
                    position: 0,
                    content: "• Onbeperkt aantal eigen nummers opslaan"
                }, 
                {
                    position: 1,
                    content: "• Onbeperkt aantal eigen thema's opslaan"
                }, 
                {
                    position: 2,
                    content: "• Onbeperkt bijbelteksten dia's genereren en opslaan"
                },
                {
                    position: 3,
                    content: "• Meerdere gebruikers mogelijk: 3 euro per gebruiker"
                }
            ],
            button: "€6,- per maand"
        }
    }

    static getSong () {
        return {
            id: 3,
            name: "Song",
            features: [
                {
                    position: 0,
                    content: "• Onbeperkt aantal eigen nummers opslaan"
                }, 
                {
                    position: 1,
                    content: "• Onbeperkt aantal eigen thema's opslaan"
                },
                {
                    position: 2,
                    content: "• Maximaal 1 apparaat",
                },
                {
                    position: 3,
                    content: "• 100 nummers met tekst en muziek"
                }
            ],
            button: "€10 per maand"
        }
    }
}

module.exports = ContractNL


// class ContractNL {
//     static getFree () {
//         return {
//             id: 1,
//             name: "Gratis",
//             features: [
//                 "• Maximaal 10 eigen nummers opslaan",
//                 "• Onbeperkt aantal eigen thema's opslaan",
//                 "• Onbeperkt bijbelteksten dia's genereren en opslaan",
//                 "• Maximaal 1 apparaat"
//             ],
//             button: "Gratis"
//         }
//     }

//     static getBeam () {
//         return {
//             id: 2,
//             name: "Beam",
//             features: [
//                 "• Onbeperkt aantal eigen nummers opslaan",
//                 "• Onbeperkt aantal eigen thema's opslaan",
//                 "• Meerdere gebruikers mogelijk: 3 euro per gebruiker"
//             ],
//             button: "€6,- per maand"
//         }
//     }

//     static getSong () {
//         return {
//             id: 3,
//             name: "Song",
//             features: [
//                 "• Onbeperkt aantal eigen nummers opslaan",
//                 "• Onbeperkt bijbelteksten dia's genereren en opslaan",
//                 "• Maximaal 1 apparaat",
//                 "• 60 nummers met tekst en muziek"
//             ],
//             button: "€10 per maand"
//         }
//     }
// }