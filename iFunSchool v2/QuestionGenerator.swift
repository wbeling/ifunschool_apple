import Foundation

struct MemoryGridItem: Identifiable, Equatable {
    let id = UUID()
    let shapeSymbol: String
    let colorName: String
}

struct Question {
    let id = UUID()
    let itemKey: String
    let text: String
    let subtext: String?
    let options: [String]
    let correctIndex: Int
    let maxTime: Double
    let flagImageName: String?
    let memorySteps: [String]?
    let memoryGridItems: [MemoryGridItem]?
    let memoryPreviewSeconds: Double?

    init(
        itemKey: String = "",
        text: String,
        subtext: String? = nil,
        options: [String],
        correctIndex: Int,
        maxTime: Double,
        flagImageName: String? = nil,
        memorySteps: [String]? = nil,
        memoryGridItems: [MemoryGridItem]? = nil,
        memoryPreviewSeconds: Double? = nil
    ) {
        self.itemKey = itemKey
        self.text = text
        self.subtext = subtext
        self.options = options
        self.correctIndex = correctIndex
        self.maxTime = maxTime
        self.flagImageName = flagImageName
        self.memorySteps = memorySteps
        self.memoryGridItems = memoryGridItems
        self.memoryPreviewSeconds = memoryPreviewSeconds
    }
}

struct ElementInfo {
    let symbol: String
    let name: String
}

struct PowerRootItem {
    let key: String
    let expression: String
    let answer: String
    let numericAnswer: Int?
    let contextCandidates: [Int]
    let distractors: [String]
    let level: GameLevel
}

struct FractionProgressItemData {
    let key: String
    let expression: String
    let questionText: String
    let subtextKey: String
    let answer: String
    let distractors: [String]
    let level: GameLevel
}

struct UnitConversionItem {
    let key: String
    let expression: String
    let questionText: String
    let answer: String
    let distractors: [String]
    let level: GameLevel
}

struct CompoundInfo {
    let formula: String
    let key: String
    let names: [String: String]
}

class QuestionGenerator {
    static let shared = QuestionGenerator()

    // Complete 118 periodic table elements
    private(set) var allElements: [ElementInfo] = [
        ElementInfo(symbol: "H", name: "Hydrogen"), ElementInfo(symbol: "He", name: "Helium"),
        ElementInfo(symbol: "Li", name: "Lithium"), ElementInfo(symbol: "Be", name: "Beryllium"),
        ElementInfo(symbol: "B", name: "Boron"), ElementInfo(symbol: "C", name: "Carbon"),
        ElementInfo(symbol: "N", name: "Nitrogen"), ElementInfo(symbol: "O", name: "Oxygen"),
        ElementInfo(symbol: "F", name: "Fluorine"), ElementInfo(symbol: "Ne", name: "Neon"),
        ElementInfo(symbol: "Na", name: "Sodium"), ElementInfo(symbol: "Mg", name: "Magnesium"),
        ElementInfo(symbol: "Al", name: "Aluminum"), ElementInfo(symbol: "Si", name: "Silicon"),
        ElementInfo(symbol: "P", name: "Phosphorus"), ElementInfo(symbol: "S", name: "Sulfur"),
        ElementInfo(symbol: "Cl", name: "Chlorine"), ElementInfo(symbol: "Ar", name: "Argon"),
        ElementInfo(symbol: "K", name: "Potassium"), ElementInfo(symbol: "Ca", name: "Calcium"),
        ElementInfo(symbol: "Sc", name: "Scandium"), ElementInfo(symbol: "Ti", name: "Titanium"),
        ElementInfo(symbol: "V", name: "Vanadium"), ElementInfo(symbol: "Cr", name: "Chromium"),
        ElementInfo(symbol: "Mn", name: "Manganese"), ElementInfo(symbol: "Fe", name: "Iron"),
        ElementInfo(symbol: "Co", name: "Cobalt"), ElementInfo(symbol: "Ni", name: "Nickel"),
        ElementInfo(symbol: "Cu", name: "Copper"), ElementInfo(symbol: "Zn", name: "Zinc"),
        ElementInfo(symbol: "Ga", name: "Gallium"), ElementInfo(symbol: "Ge", name: "Germanium"),
        ElementInfo(symbol: "As", name: "Arsenic"), ElementInfo(symbol: "Se", name: "Selenium"),
        ElementInfo(symbol: "Br", name: "Bromine"), ElementInfo(symbol: "Kr", name: "Krypton"),
        ElementInfo(symbol: "Rb", name: "Rubidium"), ElementInfo(symbol: "Sr", name: "Strontium"),
        ElementInfo(symbol: "Y", name: "Yttrium"), ElementInfo(symbol: "Zr", name: "Zirconium"),
        ElementInfo(symbol: "Nb", name: "Niobium"), ElementInfo(symbol: "Mo", name: "Molybdenum"),
        ElementInfo(symbol: "Tc", name: "Technetium"), ElementInfo(symbol: "Ru", name: "Ruthenium"),
        ElementInfo(symbol: "Rh", name: "Rhodium"), ElementInfo(symbol: "Pd", name: "Palladium"),
        ElementInfo(symbol: "Ag", name: "Silver"), ElementInfo(symbol: "Cd", name: "Cadmium"),
        ElementInfo(symbol: "In", name: "Indium"), ElementInfo(symbol: "Sn", name: "Tin"),
        ElementInfo(symbol: "Sb", name: "Antimony"), ElementInfo(symbol: "Te", name: "Tellurium"),
        ElementInfo(symbol: "I", name: "Iodine"), ElementInfo(symbol: "Xe", name: "Xenon"),
        ElementInfo(symbol: "Cs", name: "Cesium"), ElementInfo(symbol: "Ba", name: "Barium"),
        ElementInfo(symbol: "La", name: "Lanthanum"), ElementInfo(symbol: "Ce", name: "Cerium"),
        ElementInfo(symbol: "Pr", name: "Praseodymium"), ElementInfo(symbol: "Nd", name: "Neodymium"),
        ElementInfo(symbol: "Pm", name: "Promethium"), ElementInfo(symbol: "Sm", name: "Samarium"),
        ElementInfo(symbol: "Eu", name: "Europium"), ElementInfo(symbol: "Gd", name: "Gadolinium"),
        ElementInfo(symbol: "Tb", name: "Terbium"), ElementInfo(symbol: "Dy", name: "Dysprosium"),
        ElementInfo(symbol: "Ho", name: "Holmium"), ElementInfo(symbol: "Er", name: "Erbium"),
        ElementInfo(symbol: "Tm", name: "Thulium"), ElementInfo(symbol: "Yb", name: "Ytterbium"),
        ElementInfo(symbol: "Lu", name: "Lutetium"), ElementInfo(symbol: "Hf", name: "Hafnium"),
        ElementInfo(symbol: "Ta", name: "Tantalum"), ElementInfo(symbol: "W", name: "Tungsten"),
        ElementInfo(symbol: "Re", name: "Rhenium"), ElementInfo(symbol: "Os", name: "Osmium"),
        ElementInfo(symbol: "Ir", name: "Iridium"), ElementInfo(symbol: "Pt", name: "Platinum"),
        ElementInfo(symbol: "Au", name: "Gold"), ElementInfo(symbol: "Hg", name: "Mercury"),
        ElementInfo(symbol: "Tl", name: "Thallium"), ElementInfo(symbol: "Pb", name: "Lead"),
        ElementInfo(symbol: "Bi", name: "Bismuth"), ElementInfo(symbol: "Po", name: "Polonium"),
        ElementInfo(symbol: "At", name: "Astatine"), ElementInfo(symbol: "Rn", name: "Radon"),
        ElementInfo(symbol: "Fr", name: "Francium"), ElementInfo(symbol: "Ra", name: "Radium"),
        ElementInfo(symbol: "Ac", name: "Actinium"), ElementInfo(symbol: "Th", name: "Thorium"),
        ElementInfo(symbol: "Pa", name: "Protactinium"), ElementInfo(symbol: "U", name: "Uranium"),
        ElementInfo(symbol: "Np", name: "Neptunium"), ElementInfo(symbol: "Pu", name: "Plutonium"),
        ElementInfo(symbol: "Am", name: "Americium"), ElementInfo(symbol: "Cm", name: "Curium"),
        ElementInfo(symbol: "Bk", name: "Berkelium"), ElementInfo(symbol: "Cf", name: "Californium"),
        ElementInfo(symbol: "Es", name: "Einsteinium"), ElementInfo(symbol: "Fm", name: "Fermium"),
        ElementInfo(symbol: "Md", name: "Mendelevium"), ElementInfo(symbol: "No", name: "Nobelium"),
        ElementInfo(symbol: "Lr", name: "Lawrencium"), ElementInfo(symbol: "Rf", name: "Rutherfordium"),
        ElementInfo(symbol: "Db", name: "Dubnium"), ElementInfo(symbol: "Sg", name: "Seaborgium"),
        ElementInfo(symbol: "Bh", name: "Bohrium"), ElementInfo(symbol: "Hs", name: "Hassium"),
        ElementInfo(symbol: "Mt", name: "Meitnerium"), ElementInfo(symbol: "Ds", name: "Darmstadtium"),
        ElementInfo(symbol: "Rg", name: "Roentgenium"), ElementInfo(symbol: "Cn", name: "Copernicium"),
        ElementInfo(symbol: "Uut", name: "Nihonium"), ElementInfo(symbol: "Uuq", name: "Flerovium"),
        ElementInfo(symbol: "Uup", name: "Moscovium"), ElementInfo(symbol: "Uuh", name: "Livermorium"),
        ElementInfo(symbol: "Uus", name: "Tennessine"), ElementInfo(symbol: "Uuo", name: "Oganesson")
    ]
    // Complete 203-country list from panstwa.dat
    private(set) var allCountries: [String] = [
        "People's Republic of China", "India", "United States", "Indonesia", "Brazil", "Pakistan", "Nigeria", "Russia", "Japan", "Mexico",
        "Philippines", "Vietnam", "Germany", "Egypt", "Ethiopia", "Iran", "Turkey", "France", "United Kingdom", "Italy",
        "South Africa", "South Korea", "Spain", "Colombia", "Poland", "Australia", "Austria", "Belgium", "Bosnia and Herzegovina", "Chile",
        "Croatia", "Cuba", "Cyprus", "Czech Republic", "Estonia", "Finland", "Hungary", "Iceland", "Iraq", "Ireland",
        "Israel", "Luxembourg", "Macedonia", "Portugal", "Slovakia", "Slovenia", "Ukraine", "Vatican City", "Zimbabwe", "Sudan",
        "Algeria", "Canada", "Morocco", "Abkhazia", "Afghanistan", "Albania", "Andorra", "Angola", "Antigua and Barbuda", "Argentina",
        "Armenia", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belize", "Benin", "Bhutan",
        "Bolivia", "Botswana", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Cape Verde", "Central African Republic",
        "Chad", "Comoros", "Costa Rica", "Cote d'Ivoire", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor",
        "Ecuador", "El Salvador", "Equatorial Guinea", "Eritrea", "Federated States of Micronesia", "Fiji", "Gabon", "Gambia", "Georgia", "Ghana",
        "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Jamaica", "Jordan",
        "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho",
        "Liberia", "Libya", "Liechtenstein", "Lithuania", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta",
        "Marshall Islands", "Mauritania", "Mauritius", "Moldova", "Monaco", "Mongolia", "Montenegro", "Mozambique", "Myanmar", "Nagorno-Karabakh",
        "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "North Korea", "Norway", "Oman",
        "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Qatar", "Republic of China", "Republic of the Congo", "Romania",
        "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia",
        "Seychelles", "Sierra Leone", "Singapore", "Solomon Islands", "Somalia", "Somaliland", "South Ossetia", "Sri Lanka", "Suriname", "Swaziland",
        "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Transnistria", "Trinidad and Tobago",
        "Tunisia", "Turkish Republic of Northern Cyprus", "Turkmenistan", "Tuvalu", "Uganda", "United Arab Emirates", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
        "Western Sahara", "Yemen", "Zambia"
    ]

    init() {
        loadPanstwaFromFile()
    }

    func localizedCountryName(for englishName: String) -> String {
        let key = "country_\(englishName)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        return englishName
    }

    func localizedElementName(for englishName: String) -> String {
        let key = "element_\(englishName)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        return englishName
    }

    func localizedCityName(for englishName: String) -> String {
        let key = "city_\(englishName)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        return englishName
    }

    func localizedCompoundName(for compound: CompoundInfo) -> String {
        let key = "compound_\(compound.key)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        let preferredLang: String
        if let bundleLang = Bundle.main.preferredLocalizations.first?.split(separator: "-").first.map(String.init)?.lowercased() {
            preferredLang = bundleLang
        } else if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
            preferredLang = Locale.current.language.languageCode?.identifier.lowercased() ?? "en"
        } else {
            preferredLang = Locale.current.languageCode?.lowercased() ?? "en"
        }
        return compound.names[preferredLang] ?? compound.names["en"] ?? compound.formula
    }

    // Complete 203-country cities mapping: first element is ALWAYS the capital,
    // subsequent elements (up to 3 additional) are largest non-capital cities in that country.
    private(set) var countryCities: [String: [String]] = [
        // --- EUROPE (46) ---
        "Poland": ["Warsaw", "Krakow", "Lodz", "Wroclaw"],
        "Germany": ["Berlin", "Hamburg", "Munich", "Cologne"],
        "France": ["Paris", "Marseille", "Lyon", "Toulouse"],
        "United Kingdom": ["London", "Birmingham", "Manchester", "Glasgow"],
        "Italy": ["Rome", "Milan", "Naples", "Turin"],
        "Spain": ["Madrid", "Barcelona", "Valencia", "Seville"],
        "Russia": ["Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg"],
        "Ukraine": ["Kyiv", "Kharkiv", "Odesa", "Dnipro"],
        "Austria": ["Vienna", "Graz", "Linz", "Salzburg"],
        "Belgium": ["Brussels", "Antwerp", "Ghent", "Charleroi"],
        "Netherlands": ["Amsterdam", "Rotterdam", "The Hague", "Utrecht"],
        "Switzerland": ["Bern", "Zurich", "Geneva", "Basel"],
        "Sweden": ["Stockholm", "Gothenburg", "Malmo", "Uppsala"],
        "Norway": ["Oslo", "Bergen", "Trondheim", "Stavanger"],
        "Denmark": ["Copenhagen", "Aarhus", "Odense", "Aalborg"],
        "Finland": ["Helsinki", "Espoo", "Tampere", "Turku"],
        "Portugal": ["Lisbon", "Porto", "Braga", "Coimbra"],
        "Greece": ["Athens", "Thessaloniki", "Patras", "Heraklion"],
        "Czech Republic": ["Prague", "Brno", "Ostrava", "Plzen"],
        "Hungary": ["Budapest", "Debrecen", "Szeged", "Miskolc"],
        "Romania": ["Bucharest", "Cluj-Napoca", "Timisoara", "Iasi"],
        "Bulgaria": ["Sofia", "Plovdiv", "Varna", "Burgas"],
        "Croatia": ["Zagreb", "Split", "Rijeka", "Osijek"],
        "Serbia": ["Belgrade", "Novi Sad", "Nis", "Kragujevac"],
        "Slovakia": ["Bratislava", "Kosice", "Presov", "Zilina"],
        "Slovenia": ["Ljubljana", "Maribor", "Celje", "Kranj"],
        "Ireland": ["Dublin", "Cork", "Limerick", "Galway"],
        "Belarus": ["Minsk", "Gomel", "Mogilev", "Vitebsk"],
        "Lithuania": ["Vilnius", "Kaunas", "Klaipeda", "Siauliai"],
        "Latvia": ["Riga", "Daugavpils", "Liepaja", "Jelgava"],
        "Estonia": ["Tallinn", "Tartu", "Narva", "Parnu"],
        "Bosnia and Herzegovina": ["Sarajevo", "Banja Luka", "Tuzla", "Zenica"],
        "Albania": ["Tirana", "Durres", "Vlore", "Shkoder"],
        "Macedonia": ["Skopje", "Bitola", "Kumanovo", "Prilep"],
        "Moldova": ["Chisinau"],
        "Montenegro": ["Podgorica"],
        "Kosovo": ["Pristina"],
        "Iceland": ["Reykjavik"],
        "Luxembourg": ["Luxembourg City"],
        "Cyprus": ["Nicosia"],
        "Malta": ["Valletta"],
        "Andorra": ["Andorra la Vella"],
        "Liechtenstein": ["Vaduz"],
        "Monaco": ["Monaco"],
        "San Marino": ["San Marino"],
        "Vatican City": ["Vatican City"],

        // --- AMERICAS (35) ---
        "United States": ["Washington", "New York", "Los Angeles", "Chicago"],
        "Canada": ["Ottawa", "Toronto", "Montreal", "Vancouver"],
        "Mexico": ["Mexico City", "Guadalajara", "Monterrey", "Puebla"],
        "Brazil": ["Brasilia", "Sao Paulo", "Rio de Janeiro", "Salvador"],
        "Argentina": ["Buenos Aires", "Cordoba", "Rosario", "Mendoza"],
        "Colombia": ["Bogota", "Medellin", "Cali", "Barranquilla"],
        "Chile": ["Santiago", "Valparaiso", "Concepcion", "Antofagasta"],
        "Peru": ["Lima", "Arequipa", "Trujillo", "Cusco"],
        "Venezuela": ["Caracas", "Maracaibo", "Valencia (Venezuela)", "Barquisimeto"],
        "Ecuador": ["Quito", "Guayaquil", "Cuenca", "Santo Domingo (Ecuador)"],
        "Bolivia": ["Sucre", "La Paz", "Santa Cruz de la Sierra", "Cochabamba"],
        "Cuba": ["Havana", "Santiago de Cuba", "Camaguey", "Holguin"],
        "Uruguay": ["Montevideo"],
        "Paraguay": ["Asuncion"],
        "Costa Rica": ["San Jose"],
        "Panama": ["Panama City"],
        "Dominican Republic": ["Santo Domingo"],
        "Guatemala": ["Guatemala City"],
        "Honduras": ["Tegucigalpa"],
        "El Salvador": ["San Salvador"],
        "Nicaragua": ["Managua"],
        "Jamaica": ["Kingston"],
        "Haiti": ["Port-au-Prince"],
        "Trinidad and Tobago": ["Port of Spain"],
        "Bahamas": ["Nassau"],
        "Barbados": ["Bridgetown"],
        "Belize": ["Belmopan", "Belize City", "San Ignacio", "Orange Walk"],
        "Guyana": ["Georgetown"],
        "Suriname": ["Paramaribo"],
        "Antigua and Barbuda": ["Saint John's"],
        "Dominica": ["Roseau"],
        "Grenada": ["Saint George's"],
        "Saint Kitts and Nevis": ["Basseterre"],
        "Saint Lucia": ["Castries"],
        "Saint Vincent and the Grenadines": ["Kingstown"],

        // --- ASIA (48) ---
        "People's Republic of China": ["Beijing", "Shanghai", "Guangzhou", "Shenzhen"],
        "India": ["New Delhi", "Mumbai", "Bengaluru", "Kolkata"],
        "Japan": ["Tokyo", "Yokohama", "Osaka", "Nagoya"],
        "South Korea": ["Seoul", "Busan", "Incheon", "Daegu"],
        "Indonesia": ["Jakarta", "Surabaya", "Bandung", "Medan"],
        "Pakistan": ["Islamabad", "Karachi", "Lahore", "Faisalabad"],
        "Philippines": ["Manila", "Quezon City", "Davao", "Cebu City"],
        "Vietnam": ["Hanoi", "Ho Chi Minh City", "Da Nang", "Haiphong"],
        "Turkey": ["Ankara", "Istanbul", "Izmir", "Bursa"],
        "Iran": ["Tehran", "Mashhad", "Isfahan", "Tabriz"],
        "Thailand": ["Bangkok", "Chiang Mai", "Phuket", "Pattaya"],
        "Saudi Arabia": ["Riyadh", "Jeddah", "Mecca", "Medina"],
        "United Arab Emirates": ["Abu Dhabi", "Dubai", "Sharjah", "Al Ain"],
        "Israel": ["Jerusalem", "Tel Aviv", "Haifa", "Rishon LeZion"],
        "Iraq": ["Baghdad", "Basra", "Mosul", "Erbil"],
        "Malaysia": ["Kuala Lumpur", "George Town", "Ipoh", "Johor Bahru"],
        "Kazakhstan": ["Astana", "Almaty", "Shymkent", "Karaganda"],
        "Republic of China": ["Taipei", "Kaohsiung", "Taichung", "Tainan"],
        "Bangladesh": ["Dhaka", "Chittagong", "Khulna", "Rajshahi"],
        "Myanmar": ["Naypyidaw", "Yangon", "Mandalay", "Mawlamyine"],
        "Sri Lanka": ["Sri Jayawardenepura Kotte", "Colombo", "Kandy", "Galle"],
        "Syria": ["Damascus", "Aleppo", "Homs", "Latakia"],
        "Uzbekistan": ["Tashkent", "Samarkand", "Bukhara", "Namangan"],
        "Afghanistan": ["Kabul"],
        "Armenia": ["Yerevan"],
        "Azerbaijan": ["Baku"],
        "Bahrain": ["Manama"],
        "Bhutan": ["Thimphu"],
        "Brunei": ["Bandar Seri Begawan"],
        "Cambodia": ["Phnom Penh"],
        "East Timor": ["Dili"],
        "Georgia": ["Tbilisi"],
        "Jordan": ["Amman"],
        "Kuwait": ["Kuwait City"],
        "Kyrgyzstan": ["Bishkek"],
        "Laos": ["Vientiane"],
        "Lebanon": ["Beirut"],
        "Maldives": ["Male"],
        "Mongolia": ["Ulaanbaatar"],
        "Nepal": ["Kathmandu"],
        "North Korea": ["Pyongyang"],
        "Oman": ["Muscat"],
        "Palestine": ["Ramallah"],
        "Qatar": ["Doha"],
        "Singapore": ["Singapore"],
        "Tajikistan": ["Dushanbe"],
        "Turkmenistan": ["Ashgabat"],
        "Yemen": ["Sanaa"],

        // --- AFRICA (54) ---
        "Nigeria": ["Abuja", "Lagos", "Kano", "Ibadan"],
        "Egypt": ["Cairo", "Alexandria", "Giza", "Luxor"],
        "South Africa": ["Pretoria", "Johannesburg", "Cape Town", "Durban"],
        "Morocco": ["Rabat", "Casablanca", "Marrakesh", "Fes"],
        "Algeria": ["Algiers", "Oran", "Constantine", "Annaba"],
        "Ethiopia": ["Addis Ababa", "Dire Dawa", "Mekelle", "Gondar"],
        "Kenya": ["Nairobi", "Mombasa", "Kisumu", "Nakuru"],
        "Tanzania": ["Dodoma", "Dar es Salaam", "Mwanza", "Arusha"],
        "Cote d'Ivoire": ["Yamoussoukro", "Abidjan", "Bouake", "Daloa"],
        "Cameroon": ["Yaounde", "Douala", "Garoua", "Bamenda"],
        "Ghana": ["Accra", "Kumasi", "Tamale", "Takoradi"],
        "Senegal": ["Dakar"],
        "Tunisia": ["Tunis"],
        "Uganda": ["Kampala"],
        "Zimbabwe": ["Harare"],
        "Sudan": ["Khartoum"],
        "Angola": ["Luanda"],
        "Benin": ["Porto-Novo", "Cotonou", "Parakou", "Djougou"],
        "Botswana": ["Gaborone"],
        "Burkina Faso": ["Ouagadougou"],
        "Burundi": ["Gitega", "Bujumbura", "Ngozi", "Rumonge"],
        "Cape Verde": ["Praia"],
        "Central African Republic": ["Bangui"],
        "Chad": ["N'Djamena"],
        "Comoros": ["Moroni"],
        "Democratic Republic of the Congo": ["Kinshasa"],
        "Djibouti": ["Djibouti City"],
        "Equatorial Guinea": ["Malabo", "Bata", "Ebebiyin", "Aconibe"],
        "Eritrea": ["Asmara"],
        "Gabon": ["Libreville"],
        "Gambia": ["Banjul"],
        "Guinea": ["Conakry"],
        "Guinea-Bissau": ["Bissau"],
        "Lesotho": ["Maseru"],
        "Liberia": ["Monrovia"],
        "Libya": ["Tripoli"],
        "Madagascar": ["Antananarivo"],
        "Malawi": ["Lilongwe"],
        "Mali": ["Bamako"],
        "Mauritania": ["Nouakchott"],
        "Mauritius": ["Port Louis"],
        "Mozambique": ["Maputo"],
        "Namibia": ["Windhoek"],
        "Niger": ["Niamey"],
        "Republic of the Congo": ["Brazzaville"],
        "Rwanda": ["Kigali"],
        "Sao Tome and Principe": ["Sao Tome"],
        "Seychelles": ["Victoria"],
        "Sierra Leone": ["Freetown"],
        "Somalia": ["Mogadishu"],
        "Swaziland": ["Mbabane"],
        "Togo": ["Lome"],
        "Western Sahara": ["Laayoune"],
        "Zambia": ["Lusaka"],

        // --- OCEANIA & SPECIAL TERRITORIES (20) ---
        "Australia": ["Canberra", "Sydney", "Melbourne", "Brisbane"],
        "New Zealand": ["Wellington", "Auckland", "Christchurch", "Hamilton"],
        "Papua New Guinea": ["Port Moresby"],
        "Fiji": ["Suva"],
        "Solomon Islands": ["Honiara"],
        "Vanuatu": ["Port Vila"],
        "Samoa": ["Apia"],
        "Tonga": ["Nuku'alofa"],
        "Kiribati": ["South Tarawa"],
        "Federated States of Micronesia": ["Palikir"],
        "Marshall Islands": ["Majuro"],
        "Palau": ["Ngerulmud"],
        "Nauru": ["Yaren"],
        "Tuvalu": ["Funafuti"],
        "Abkhazia": ["Sukhumi"],
        "Nagorno-Karabakh": ["Stepanakert"],
        "Somaliland": ["Hargeisa"],
        "South Ossetia": ["Tskhinvali"],
        "Transnistria": ["Tiraspol"],
        "Turkish Republic of Northern Cyprus": ["North Nicosia"]
    ]

    // Level 0 (Beginner): Europe
    private let europeanCountries: [String] = [
        "Poland", "Germany", "France", "United Kingdom", "Italy", "Spain", "Russia", "Ukraine",
        "Austria", "Belgium", "Netherlands", "Switzerland", "Sweden", "Norway", "Denmark", "Finland",
        "Portugal", "Greece", "Czech Republic", "Hungary", "Romania", "Bulgaria", "Croatia", "Serbia",
        "Slovakia", "Slovenia", "Ireland", "Belarus", "Lithuania", "Latvia", "Estonia",
        "Bosnia and Herzegovina", "Albania", "Macedonia", "Moldova", "Montenegro", "Kosovo",
        "Iceland", "Luxembourg", "Cyprus", "Malta", "Andorra", "Liechtenstein", "Monaco",
        "San Marino", "Vatican City"
    ]

    // Level 1 (Easy): Americas
    private let americanCountries: [String] = [
        "United States", "Canada", "Mexico", "Brazil", "Argentina", "Colombia", "Chile", "Peru",
        "Venezuela", "Ecuador", "Bolivia", "Cuba", "Uruguay", "Paraguay", "Costa Rica", "Panama",
        "Dominican Republic", "Guatemala", "Honduras", "El Salvador", "Nicaragua", "Jamaica",
        "Haiti", "Trinidad and Tobago", "Bahamas", "Barbados", "Belize", "Guyana", "Suriname",
        "Antigua and Barbuda", "Dominica", "Grenada", "Saint Kitts and Nevis", "Saint Lucia",
        "Saint Vincent and the Grenadines"
    ]

    // Level 2 (Medium): Asia
    private let asianCountries: [String] = [
        "People's Republic of China", "India", "Japan", "South Korea", "Indonesia", "Pakistan",
        "Philippines", "Vietnam", "Turkey", "Iran", "Thailand", "Saudi Arabia",
        "United Arab Emirates", "Israel", "Iraq", "Malaysia", "Kazakhstan", "Republic of China",
        "Bangladesh", "Myanmar", "Sri Lanka", "Syria", "Uzbekistan", "Afghanistan", "Armenia",
        "Azerbaijan", "Bahrain", "Bhutan", "Brunei", "Cambodia", "East Timor", "Georgia",
        "Jordan", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Maldives", "Mongolia", "Nepal",
        "North Korea", "Oman", "Palestine", "Qatar", "Singapore", "Tajikistan", "Turkmenistan", "Yemen"
    ]

    // Level 3 (Hard): Africa
    private let africanCountries: [String] = [
        "Nigeria", "Egypt", "South Africa", "Morocco", "Algeria", "Ethiopia", "Kenya", "Tanzania",
        "Cote d'Ivoire", "Cameroon", "Ghana", "Senegal", "Tunisia", "Uganda", "Zimbabwe", "Sudan",
        "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cape Verde",
        "Central African Republic", "Chad", "Comoros", "Democratic Republic of the Congo",
        "Djibouti", "Equatorial Guinea", "Eritrea", "Gabon", "Gambia", "Guinea", "Guinea-Bissau",
        "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius",
        "Mozambique", "Namibia", "Niger", "Republic of the Congo", "Rwanda",
        "Sao Tome and Principe", "Seychelles", "Sierra Leone", "Somalia", "Swaziland", "Togo",
        "Western Sahara", "Zambia"
    ]

    // Level 4 (Ultimate): Selected hard countries from around the world
    private let worldHardCountries: [String] = [
        // Oceania & Pacific
        "Australia", "New Zealand", "Papua New Guinea", "Fiji", "Solomon Islands", "Vanuatu",
        "Samoa", "Tonga", "Kiribati", "Federated States of Micronesia", "Marshall Islands",
        "Palau", "Nauru", "Tuvalu",
        // De facto / Partially recognized territories
        "Abkhazia", "Nagorno-Karabakh", "Somaliland", "South Ossetia", "Transnistria",
        "Turkish Republic of Northern Cyprus", "Western Sahara", "Kosovo",
        // Tricky / non-largest-city capitals & difficult countries globally
        "Sri Lanka", "Myanmar", "Tanzania", "Cote d'Ivoire", "Burundi", "Belize", "Bolivia",
        "Benin", "Equatorial Guinea", "Swaziland", "Nigeria", "Kazakhstan", "Bhutan", "Brunei",
        "East Timor", "Turkmenistan", "Tajikistan", "Kyrgyzstan", "Suriname", "Guyana",
        "Antigua and Barbuda", "Saint Kitts and Nevis", "Saint Vincent and the Grenadines",
        "Dominica", "Grenada", "Saint Lucia", "Comoros", "Cape Verde", "Sao Tome and Principe",
        "Gambia", "Guinea-Bissau", "Eritrea", "Lesotho", "Malawi", "Mauritania", "Chad",
        "Central African Republic", "Gabon", "Togo", "Sierra Leone", "Liechtenstein", "Andorra"
    ]

    func capitalCity(for country: String) -> String {
        return countryCities[country]?.first ?? country
    }

    func cities(for country: String) -> [String] {
        return countryCities[country] ?? [country]
    }

    func capitalsPool(for level: GameLevel) -> [String] {
        switch level {
        case .beginner:
            return europeanCountries
        case .easy:
            return americanCountries
        case .medium:
            return asianCountries
        case .hard:
            return africanCountries
        case .ultimate:
            return worldHardCountries
        case .godlike:
            return allCountries
        }
    }

    private func loadPanstwaFromFile() {
        if let path = Bundle.main.path(forResource: "panstwa", ofType: "dat"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let cleanContent = content.replacingOccurrences(of: "\u{FEFF}", with: "")
            let loaded = cleanContent.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !loaded.isEmpty {
                self.allCountries = loaded
            }
        }
    }

    func getMaxTime(for level: GameLevel) -> Double {
        switch level {
        case .beginner: return 20.0
        case .easy: return 25.0
        case .medium: return 30.0
        case .hard: return 35.0
        case .ultimate: return 40.0
        case .godlike: return 45.0
        }
    }

    func TotalQuestions(for level: GameLevel) -> Int {
        return 15
    }

    func scoreMultiplier(for level: GameLevel) -> Double {
        switch level {
        case .beginner: return 1.0
        case .easy: return 20.0 / 15.0      // 1.3333x
        case .medium: return 25.0 / 15.0    // 1.6667x
        case .hard: return 30.0 / 15.0      // 2.0x
        case .ultimate: return 35.0 / 15.0  // 2.3333x
        case .godlike: return 40.0 / 15.0   // 2.6667x
        }
    }

    func generateQuestion(gameType: GameType, level: GameLevel, questionIndex: Int = 0) -> Question {
        let time = getMaxTime(for: level)

        switch gameType {
        case .addition:
            return generateAddition(level: level, maxTime: time, questionIndex: questionIndex)
        case .subtraction:
            return generateSubtraction(level: level, maxTime: time, questionIndex: questionIndex)
        case .multiplication:
            return generateMultiplication(level: level, maxTime: time, questionIndex: questionIndex)
        case .division:
            return generateDivision(level: level, maxTime: time, questionIndex: questionIndex)
        case .order:
            return generateOrderOfOperations(level: level, maxTime: time, questionIndex: questionIndex)
        case .sequences:
            return generateSequences(level: level, maxTime: time, questionIndex: questionIndex)
        case .equations:
            return generateEquations(level: level, maxTime: time, questionIndex: questionIndex)
        case .memoryAdd:
            return generateMemoryAdd(level: level, maxTime: time, questionIndex: questionIndex)
        case .memoryAddSub:
            return generateMemoryAddSub(level: level, maxTime: time, questionIndex: questionIndex)
        case .memoryAddSubMult:
            return generateMemoryAddSubMult(level: level, maxTime: time, questionIndex: questionIndex)
        case .memoryShapes:
            return generateMemoryShapes(level: level, maxTime: time, questionIndex: questionIndex)
        case .memoryColors:
            return generateMemoryColors(level: level, maxTime: time, questionIndex: questionIndex)
        case .chemSymbols:
            return generateChemSymbols(level: level, maxTime: time)
        case .chemNames:
            return generateChemNames(level: level, maxTime: time)
        case .flags:
            return generateFlags(level: level, maxTime: time)
        case .capitals:
            return generateCapitals(level: level, maxTime: time)
        case .romanNumerals:
            return generateRomanNumerals(level: level, maxTime: time)
        case .powersRoots:
            return generatePowersRoots(level: level, maxTime: time)
        case .fractions:
            return generateFractions(level: level, maxTime: time)
        case .unitConversions:
            return generateUnitConversions(level: level, maxTime: time)
        case .chemCompounds:
            return generateChemCompounds(level: level, maxTime: time)
        }
    }

    // Helper for chemical elements range index selection matching periodic table progression
    private func selectElementIndex(level: GameLevel) -> Int {
        let total = allElements.count
        guard total > 0 else { return 0 }

        switch level {
        case .beginner:
            return Int.random(in: 0..<min(25, total))
        case .easy:
            return Int.random(in: 0..<min(50, total))
        case .medium:
            return Int.random(in: min(20, total - 1)..<min(70, total))
        case .hard:
            return Int.random(in: min(40, total - 1)..<min(95, total))
        case .ultimate:
            return Int.random(in: min(60, total - 1)..<min(105, total))
        case .godlike:
            return Int.random(in: min(70, total - 1)..<total)
        }
    }

    // Clusters of visually confusing flags for realistic distractors on high levels
    private let confusingCountryClusters: [[String]] = [
        ["Chad", "Romania", "Moldova", "Andorra"],
        ["Monaco", "Indonesia", "Poland", "Singapore"],
        ["Australia", "New Zealand", "Tuvalu", "Fiji"],
        ["Ireland", "Cote d'Ivoire", "Italy", "India"],
        ["Mali", "Guinea", "Senegal", "Cameroon", "Ghana"],
        ["Netherlands", "Luxembourg", "France", "Russia"],
        ["Slovakia", "Slovenia", "Russia", "Serbia", "Croatia"],
        ["Norway", "Sweden", "Finland", "Iceland", "Denmark"],
        ["Egypt", "Syria", "Iraq", "Yemen", "Jordan", "Sudan"],
        ["Venezuela", "Colombia", "Ecuador"],
        ["El Salvador", "Honduras", "Nicaragua", "Guatemala", "Argentina"],
        ["Bahrain", "Qatar", "United Arab Emirates", "Kuwait"]
    ]

    // Regional geographic clusters
    private let regionalCountryPools: [[String]] = [
        ["Estonia", "Latvia", "Lithuania"],
        ["Croatia", "Serbia", "Bosnia and Herzegovina", "Montenegro", "Macedonia", "Albania", "Bulgaria", "Greece", "Slovenia"],
        ["Tuvalu", "Fiji", "Kiribati", "Nauru", "Palau", "Marshall Islands", "Solomon Islands", "Vanuatu", "Samoa", "Tonga", "Federated States of Micronesia"],
        ["Kazakhstan", "Uzbekistan", "Kyrgyzstan", "Tajikistan", "Turkmenistan"],
        ["Nigeria", "Ghana", "Senegal", "Mali", "Guinea", "Guinea-Bissau", "Benin", "Togo", "Burkina Faso", "Sierra Leone", "Liberia"],
        ["Guatemala", "Honduras", "El Salvador", "Nicaragua", "Costa Rica", "Panama", "Belize"],
        ["Brazil", "Argentina", "Colombia", "Chile", "Peru", "Venezuela", "Ecuador", "Bolivia", "Paraguay", "Uruguay"],
        ["Cuba", "Jamaica", "Haiti", "Dominican Republic", "Bahamas", "Barbados", "Saint Lucia", "Trinidad and Tobago"],
        ["Kenya", "Tanzania", "Uganda", "Rwanda", "Burundi", "Ethiopia", "Somalia"],
        ["Austria", "Germany", "Switzerland", "Liechtenstein", "Luxembourg", "Belgium", "Netherlands"]
    ]

    // Similar name traps
    private let similarNameClusters: [[String]] = [
        ["Slovakia", "Slovenia"],
        ["Niger", "Nigeria"],
        ["Guinea", "Guinea-Bissau", "Equatorial Guinea"],
        ["Republic of the Congo", "Democratic Republic of the Congo"],
        ["Dominica", "Dominican Republic"],
        ["Sudan", "South Sudan"],
        ["Austria", "Australia"]
    ]

    private func pickCountryDistractors(targetCountry: String, level: GameLevel) -> [String] {
        var choicesSet = Set<String>([targetCountry])

        var visualCandidates: [String] = []
        for cluster in confusingCountryClusters {
            if cluster.contains(targetCountry) {
                visualCandidates.append(contentsOf: cluster.filter { $0 != targetCountry && allCountries.contains($0) })
            }
        }

        var regionalCandidates: [String] = []
        for pool in regionalCountryPools {
            if pool.contains(targetCountry) {
                regionalCandidates.append(contentsOf: pool.filter { $0 != targetCountry && allCountries.contains($0) })
            }
        }

        var nameCandidates: [String] = []
        for cluster in similarNameClusters {
            if cluster.contains(targetCountry) {
                nameCandidates.append(contentsOf: cluster.filter { $0 != targetCountry && allCountries.contains($0) })
            }
        }

        let total = allCountries.count
        let tierCountries: [String]
        switch level {
        case .beginner: tierCountries = Array(allCountries.prefix(min(35, total)))
        case .easy: tierCountries = Array(allCountries.prefix(min(60, total)))
        case .medium: tierCountries = Array(allCountries[min(20, total - 1)..<min(85, total)])
        case .hard: tierCountries = Array(allCountries[min(40, total - 1)..<min(125, total)])
        case .ultimate: tierCountries = Array(allCountries[min(60, total - 1)..<min(160, total)])
        case .godlike: tierCountries = Array(allCountries[min(80, total - 1)..<total])
        }

        let candidatePools: [[String]] = [
            visualCandidates.shuffled(),
            regionalCandidates.shuffled(),
            nameCandidates.shuffled(),
            tierCountries.filter { $0 != targetCountry }.shuffled()
        ].shuffled()

        // Round-robin selection across different strategy pools
        for pool in candidatePools {
            if choicesSet.count >= 4 { break }
            for country in pool {
                if !choicesSet.contains(country) {
                    choicesSet.insert(country)
                    break
                }
            }
        }

        // Fallback to reach 4 items
        for c in tierCountries.shuffled() {
            if choicesSet.count >= 4 { break }
            choicesSet.insert(c)
        }
        while choicesSet.count < 4 {
            if let rand = allCountries.randomElement() {
                choicesSet.insert(rand)
            }
        }
        return Array(choicesSet).shuffled()
    }

    // Chemical group / family clusters
    private let chemicalGroupClusters: [[String]] = [
        ["Li", "Na", "K", "Rb", "Cs", "Fr"],
        ["Be", "Mg", "Ca", "Sr", "Ba", "Ra"],
        ["F", "Cl", "Br", "I", "At", "Ts"],
        ["He", "Ne", "Ar", "Kr", "Xe", "Rn", "Og"],
        ["Cu", "Ag", "Au", "Pt", "Pd"],
        ["Fe", "Co", "Ni", "Zn", "Mn", "Cr"],
        ["Al", "Ga", "In", "Sn", "Tl", "Pb", "Bi"],
        ["B", "Si", "Ge", "As", "Sb", "Te"]
    ]

    // Common symbol & phonetic confusion clusters
    private let chemicalConfusionClusters: [[String]] = [
        ["Na", "N", "Ni", "Ne", "Nb"],
        ["K", "P", "Pb", "Pt", "Po"],
        ["Ag", "Au", "Al", "Ar", "As"],
        ["Cu", "Co", "Cr", "C", "Ca", "Cl"],
        ["Fe", "F", "Fr", "Fm"],
        ["Mg", "Mn", "Mo"],
        ["S", "Si", "Sn", "Sb", "Sc", "Se"],
        ["Hg", "H", "He", "Hf", "Hs"],
        ["Ba", "Be", "Bi", "Bk", "Bh", "B"],
        ["Ta", "Tl", "Ti", "Tb", "Te", "Tc"]
    ]

    private func pickChemSymbolDistractors(targetElem: ElementInfo, level: GameLevel) -> [String] {
        var choicesSet = Set<String>([targetElem.name])

        // 1. Group candidates
        var groupCandidates: [String] = []
        for cluster in chemicalGroupClusters {
            if cluster.contains(targetElem.symbol) {
                let partnerSymbols = cluster.filter { $0 != targetElem.symbol }
                for sym in partnerSymbols {
                    if let elem = allElements.first(where: { $0.symbol == sym }) {
                        groupCandidates.append(elem.name)
                    }
                }
                break
            }
        }

        // 2. Confusion cluster candidates
        var confusionCandidates: [String] = []
        for cluster in chemicalConfusionClusters {
            if cluster.contains(targetElem.symbol) {
                let partnerSymbols = cluster.filter { $0 != targetElem.symbol }
                for sym in partnerSymbols {
                    if let elem = allElements.first(where: { $0.symbol == sym }) {
                        confusionCandidates.append(elem.name)
                    }
                }
                break
            }
        }

        // 3. Same first letter candidates
        let firstLetter = String(targetElem.symbol.prefix(1))
        let letterCandidates = allElements.filter { $0.symbol.hasPrefix(firstLetter) && $0.symbol != targetElem.symbol }.map { $0.name }

        // 4. Same tier candidates
        let total = allElements.count
        let tierRange: Range<Int>
        switch level {
        case .beginner: tierRange = 0..<min(25, total)
        case .easy: tierRange = 0..<min(50, total)
        case .medium: tierRange = min(20, total - 1)..<min(70, total)
        case .hard: tierRange = min(40, total - 1)..<min(95, total)
        case .ultimate: tierRange = min(60, total - 1)..<min(105, total)
        case .godlike: tierRange = min(70, total - 1)..<total
        }
        let tierCandidates = Array(allElements[tierRange]).filter { $0.symbol != targetElem.symbol }.map { $0.name }

        let candidatePools: [[String]] = [
            groupCandidates.shuffled(),
            confusionCandidates.shuffled(),
            letterCandidates.shuffled(),
            tierCandidates.shuffled()
        ].shuffled()

        for pool in candidatePools {
            if choicesSet.count >= 4 { break }
            for cand in pool {
                if !choicesSet.contains(cand) {
                    choicesSet.insert(cand)
                    break
                }
            }
        }

        for cand in tierCandidates.shuffled() {
            if choicesSet.count >= 4 { break }
            choicesSet.insert(cand)
        }
        while choicesSet.count < 4 {
            if let rand = allElements.randomElement() {
                choicesSet.insert(rand.name)
            }
        }
        return Array(choicesSet).shuffled()
    }

    private func pickChemNameDistractors(targetElem: ElementInfo, level: GameLevel) -> [String] {
        var choicesSet = Set<String>([targetElem.symbol])

        // 1. Group candidates
        var groupCandidates: [String] = []
        for cluster in chemicalGroupClusters {
            if cluster.contains(targetElem.symbol) {
                let partnerSymbols = cluster.filter { $0 != targetElem.symbol }
                groupCandidates.append(contentsOf: partnerSymbols)
                break
            }
        }

        // 2. Confusion cluster candidates
        var confusionCandidates: [String] = []
        for cluster in chemicalConfusionClusters {
            if cluster.contains(targetElem.symbol) {
                let partnerSymbols = cluster.filter { $0 != targetElem.symbol }
                confusionCandidates.append(contentsOf: partnerSymbols)
                break
            }
        }

        // 3. Same first letter candidates
        let firstLetter = String(targetElem.symbol.prefix(1))
        let letterCandidates = allElements.filter { $0.symbol.hasPrefix(firstLetter) && $0.symbol != targetElem.symbol }.map { $0.symbol }

        // 4. Same tier candidates
        let total = allElements.count
        let tierRange: Range<Int>
        switch level {
        case .beginner: tierRange = 0..<min(25, total)
        case .easy: tierRange = 0..<min(50, total)
        case .medium: tierRange = min(20, total - 1)..<min(70, total)
        case .hard: tierRange = min(40, total - 1)..<min(95, total)
        case .ultimate: tierRange = min(60, total - 1)..<min(105, total)
        case .godlike: tierRange = min(70, total - 1)..<total
        }
        let tierCandidates = Array(allElements[tierRange]).filter { $0.symbol != targetElem.symbol }.map { $0.symbol }

        let candidatePools: [[String]] = [
            groupCandidates.shuffled(),
            confusionCandidates.shuffled(),
            letterCandidates.shuffled(),
            tierCandidates.shuffled()
        ].shuffled()

        for pool in candidatePools {
            if choicesSet.count >= 4 { break }
            for cand in pool {
                if !choicesSet.contains(cand) {
                    choicesSet.insert(cand)
                    break
                }
            }
        }

        for cand in tierCandidates.shuffled() {
            if choicesSet.count >= 4 { break }
            choicesSet.insert(cand)
        }
        while choicesSet.count < 4 {
            if let rand = allElements.randomElement() {
                choicesSet.insert(rand.symbol)
            }
        }
        return Array(choicesSet).shuffled()
    }

    // MARK: - 1. Addition
    private func generateAddition(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correct: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let r1 = Int.random(in: 1...9)
            let r2 = Int.random(in: 2...9)
            correct = r1 + r2
            text = "\(r1) + \(r2)"
            range = 10
            distractorCandidates = [correct + 1, correct - 1, correct + 2, correct - 2, r1 * r2]
        case .easy:
            let r1 = Int.random(in: 1...19)
            let r2 = Int.random(in: 2...18)
            correct = r1 + r2
            text = "\(r1) + \(r2)"
            range = 10
            distractorCandidates = [correct + 10, correct - 10, correct + 1, correct - 1, correct + 9, correct + 11]
        case .medium:
            let total = Int.random(in: 20...100)
            let r1 = Int.random(in: 10...(total - 10))
            let r2 = total - r1
            correct = total
            text = "\(r1) + \(r2)"
            range = 15
            distractorCandidates = [correct + 10, correct - 10, correct + 20, correct - 20, correct + 1, correct - 1, correct + 9]
        case .hard:
            let total = Int.random(in: 100...500)
            let r1 = Int.random(in: 40...(total - 40))
            let r2 = total - r1
            correct = total
            text = "\(r1) + \(r2)"
            range = 25
            distractorCandidates = [correct + 10, correct - 10, correct + 100, correct - 100, correct + 20, correct - 20, correct + 1, correct - 1]
        case .ultimate:
            let r1 = Int.random(in: 50...300)
            let r2 = Int.random(in: 50...300)
            let r3 = Int.random(in: 50...300)
            correct = r1 + r2 + r3
            text = "\(r1) + \(r2) + \(r3)"
            range = 30
            distractorCandidates = [r1 + r2, r1 + r3, r2 + r3, r1 + r2 - r3, correct + 10, correct - 10, correct + 20, correct + 100, correct - 100]
        case .godlike:
            if questionIndex < 7 {
                let r1 = Int.random(in: 200...800)
                let r2 = Int.random(in: 200...800)
                let r3 = Int.random(in: 200...800)
                correct = r1 + r2 + r3
                text = "\(r1) + \(r2) + \(r3)"
                distractorCandidates = [r1 + r2, r1 + r2 - r3, correct + 10, correct - 10, correct + 20, correct - 20, correct + 100, correct - 100, correct + 200]
            } else {
                let r1 = Int.random(in: 150...600)
                let r2 = Int.random(in: 150...600)
                let r3 = Int.random(in: 150...600)
                let r4 = Int.random(in: 150...600)
                correct = r1 + r2 + r3 + r4
                text = "\(r1) + \(r2) + \(r3) + \(r4)"
                distractorCandidates = [r1 + r2 + r3, r1 + r2 + r3 - r4, correct + 10, correct - 10, correct + 20, correct - 20, correct + 100, correct - 100]
            }
            range = 40
        }

        let options = makeNumericOptions(correct: correct, range: range, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_sum", comment: "Calculate sum"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 2. Subtraction
    private func generateSubtraction(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correct: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let r2 = Int.random(in: 1...10)
            let diff = Int.random(in: 1...10)
            let r1 = r2 + diff
            correct = diff
            text = "\(r1) - \(r2)"
            range = 10
            distractorCandidates = [diff + 1, diff - 1, diff + 2, r1, r2]
        case .easy:
            let r2 = Int.random(in: 10...30)
            let diff = Int.random(in: 1...20)
            let r1 = r2 + diff
            correct = diff
            text = "\(r1) - \(r2)"
            range = 12
            distractorCandidates = [diff + 10, diff - 10, diff + 1, diff - 1, r1 - r2 + 2]
        case .medium:
            let r2 = Int.random(in: 10...50)
            let diff = Int.random(in: 15...50)
            let r1 = r2 + diff
            correct = diff
            text = "\(r1) - \(r2)"
            range = 15
            distractorCandidates = [diff + 10, diff - 10, diff + 1, diff - 1, diff + 9, diff - 9, diff + 20]
        case .hard:
            let r2 = Int.random(in: 50...250)
            let diff = Int.random(in: 40...200)
            let r1 = r2 + diff
            correct = diff
            text = "\(r1) - \(r2)"
            range = 25
            distractorCandidates = [diff + 10, diff - 10, diff + 100, diff - 100, diff + 20, diff - 20, diff + 1, diff - 1]
        case .ultimate:
            let r2 = Int.random(in: 40...180)
            let r3 = Int.random(in: 40...180)
            let diff = Int.random(in: 50...250)
            let r1 = r2 + r3 + diff
            correct = diff
            text = "\(r1) - \(r2) - \(r3)"
            range = 35
            distractorCandidates = [r1 - r2, r1 - r2 + r3, diff + 10, diff - 10, diff + 20, diff - 20, diff + 100]
        case .godlike:
            if questionIndex < 7 {
                let r2 = Int.random(in: 1200...4500)
                let diff = Int.random(in: 800...3500)
                let r1 = r2 + diff
                correct = diff
                text = "\(r1) - \(r2)"
                distractorCandidates = [diff + 10, diff - 10, diff + 100, diff - 100, diff + 20, diff - 20, diff + 200, diff - 200]
            } else {
                let r2 = Int.random(in: 400...1500)
                let r3 = Int.random(in: 400...1500)
                let diff = Int.random(in: 500...2000)
                let r1 = r2 + r3 + diff
                correct = diff
                text = "\(r1) - \(r2) - \(r3)"
                distractorCandidates = [r1 - r2, r1 - r2 + r3, diff + 10, diff - 10, diff + 100, diff - 100, diff + 20, diff - 20]
            }
            range = 50
        }

        let options = makeNumericOptions(correct: correct, range: range, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_diff", comment: "Calculate difference"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 3. Multiplication
    private func generateMultiplication(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correct: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let r1 = Int.random(in: 2...9)
            let r2 = Int.random(in: 2...9)
            correct = r1 * r2
            text = "\(r1) × \(r2)"
            range = 15
            distractorCandidates = [(r1 + 1) * r2, r1 * (r2 - 1), (r1 - 1) * r2, correct + 10, correct - 10, r1 + r2]
        case .easy:
            let r1 = Int.random(in: 3...9)
            let r2 = Int.random(in: 11...19)
            correct = r1 * r2
            text = "\(r1) × \(r2)"
            range = 20
            distractorCandidates = [(r1 + 1) * r2, r1 * (r2 + 1), (r1 - 1) * r2, correct + 10, correct - 10, correct + 20]
        case .medium:
            let r1 = Int.random(in: 11...25)
            let r2 = Int.random(in: 11...25)
            correct = r1 * r2
            text = "\(r1) × \(r2)"
            range = 30
            distractorCandidates = [(r1 + 1) * r2, r1 * (r2 - 1), correct + 10, correct - 10, correct + 20, correct - 20, correct + 100]
        case .hard:
            let r1 = Int.random(in: 20...50)
            let r2 = Int.random(in: 15...35)
            correct = r1 * r2
            text = "\(r1) × \(r2)"
            range = 50
            distractorCandidates = [(r1 + 1) * r2, r1 * (r2 - 1), correct + 10, correct - 10, correct + 20, correct - 20, correct + 100, correct - 100]
        case .ultimate:
            let r1 = Int.random(in: 4...9)
            let r2 = Int.random(in: 6...12)
            let r3 = Int.random(in: 8...15)
            correct = r1 * r2 * r3
            text = "\(r1) × \(r2) × \(r3)"
            range = 80
            distractorCandidates = [r1 * r2, (r1 * r2) + r3, (r1 + 1) * r2 * r3, correct + 10, correct - 10, correct + 20, correct - 20, correct + 50, correct - 50]
        case .godlike:
            if questionIndex < 7 {
                let r1 = Int.random(in: 11...16)
                let r2 = Int.random(in: 11...16)
                let r3 = Int.random(in: 11...15)
                correct = r1 * r2 * r3
                text = "\(r1) × \(r2) × \(r3)"
                distractorCandidates = [r1 * r2, (r1 * r2) + r3, (r1 + 1) * r2 * r3, r1 * (r2 - 1) * r3, correct + 10, correct - 10, correct + 20, correct - 20, correct + 100, correct - 100]
            } else {
                let r1 = Int.random(in: 120...350)
                let r2 = Int.random(in: 15...45)
                correct = r1 * r2
                text = "\(r1) × \(r2)"
                distractorCandidates = [(r1 + 1) * r2, r1 * (r2 - 1), correct + 10, correct - 10, correct + 20, correct - 20, correct + 50, correct - 50, correct + 100, correct - 100]
            }
            range = 150
        }

        let options = makeNumericOptions(correct: correct, range: range, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_product", comment: "Calculate product"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 4. Division
    private func generateDivision(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correct: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let divisor = Int.random(in: 2...9)
            let quotient = Int.random(in: 1...10)
            let dividend = divisor * quotient
            correct = quotient
            text = "\(dividend) ÷ \(divisor)"
            range = 8
            distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, divisor]
        case .easy:
            let divisor = Int.random(in: 3...10)
            let quotient = Int.random(in: 10...20)
            let dividend = divisor * quotient
            correct = quotient
            text = "\(dividend) ÷ \(divisor)"
            range = 10
            distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, quotient + 10, quotient - 10]
        case .medium:
            let divisor = Int.random(in: 10...30)
            let quotient = Int.random(in: 10...25)
            let dividend = divisor * quotient
            correct = quotient
            text = "\(dividend) ÷ \(divisor)"
            range = 15
            distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, quotient + 10, quotient - 10, quotient + 5]
        case .hard:
            let divisor = Int.random(in: 15...40)
            let quotient = Int.random(in: 20...45)
            let dividend = divisor * quotient
            correct = quotient
            text = "\(dividend) ÷ \(divisor)"
            range = 20
            distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, quotient + 10, quotient - 10, quotient + 5, quotient - 5]
        case .ultimate:
            let divisor = Int.random(in: 25...75)
            let quotient = Int.random(in: 30...85)
            let dividend = divisor * quotient
            correct = quotient
            text = "\(dividend) ÷ \(divisor)"
            range = 25
            distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, quotient + 10, quotient - 10, quotient + 20, quotient - 20]
        case .godlike:
            if questionIndex < 7 {
                let divisor = Int.random(in: 35...95)
                let quotient = Int.random(in: 55...130)
                let dividend = divisor * quotient
                correct = quotient
                text = "\(dividend) ÷ \(divisor)"
                distractorCandidates = [quotient + 1, quotient - 1, quotient + 2, quotient - 2, quotient + 10, quotient - 10, quotient + 20, quotient - 20]
            } else {
                let factor1 = Int.random(in: 4...15)
                let factor2 = Int.random(in: 5...25)
                let div = Int.random(in: 2...6)
                let bVal = factor2 * div
                correct = factor1 * factor2
                text = "(\(factor1) × \(bVal)) ÷ \(div)"
                distractorCandidates = [factor1 * bVal, (factor1 * bVal) - div, correct + 1, correct - 1, correct + 10, correct - 10, correct + 5, correct - 5]
            }
            range = 30
        }

        let options = makeNumericOptions(correct: correct, range: range, minVal: 1, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_quotient", comment: "Calculate quotient"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 5. Order of Operations
    private func generateOrderOfOperations(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correct: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let r1 = Int.random(in: 2...10)
            let r2 = Int.random(in: 2...8)
            let r3 = Int.random(in: 2...8)
            if Bool.random() {
                text = "\(r1) + \(r2) × \(r3)"
                correct = r1 + (r2 * r3)
                distractorCandidates = [(r1 + r2) * r3, (r2 * r3), correct + 1, correct - 1, correct + 10]
            } else {
                text = "\(r2) × \(r3) + \(r1)"
                correct = (r2 * r3) + r1
                distractorCandidates = [r2 * (r3 + r1), (r2 * r3), correct + 1, correct - 1, correct + 10]
            }
            range = 10
        case .easy:
            if Bool.random() {
                let r1 = Int.random(in: 3...9)
                let r2 = Int.random(in: 4...9)
                let r3 = Int.random(in: 2...min(15, r1 * r2 - 2))
                text = "\(r1) × \(r2) - \(r3)"
                correct = (r1 * r2) - r3
                distractorCandidates = [r1 * (r2 - r3), (r1 * r2), correct + 1, correct - 1, correct + 10]
            } else {
                let r1 = Int.random(in: 2...8)
                let r2 = Int.random(in: 2...8)
                let r3 = Int.random(in: 2...6)
                text = "(\(r1) + \(r2)) × \(r3)"
                correct = (r1 + r2) * r3
                distractorCandidates = [r1 + (r2 * r3), r1 + r2, correct + 1, correct - 1, correct + 10]
            }
            range = 12
        case .medium:
            let variant = Int.random(in: 0...2)
            switch variant {
            case 0:
                let r1 = Int.random(in: 3...8)
                let r2 = Int.random(in: 2...7)
                let r3 = Int.random(in: 3...8)
                let r4 = Int.random(in: 2...7)
                text = "\(r1) × \(r2) + \(r3) × \(r4)"
                correct = (r1 * r2) + (r3 * r4)
                distractorCandidates = [((r1 * r2) + r3) * r4, (r1 * r2) + r3, r1 * (r2 + r3) * r4, correct + 10, correct - 10, correct + 1]
            case 1:
                let r1 = Int.random(in: 2...8)
                let r2 = Int.random(in: 2...8)
                let r4 = Int.random(in: 2...6)
                let diff = Int.random(in: 2...6)
                let r3 = r4 + diff
                text = "(\(r1) + \(r2)) × (\(r3) - \(r4))"
                correct = (r1 + r2) * diff
                distractorCandidates = [r1 + r2 * diff, (r1 + r2) * r3 - r4, correct + 10, correct - 10, correct + 1]
            default:
                let r1 = Int.random(in: 2...10)
                let r2 = Int.random(in: 3...8)
                let r3 = Int.random(in: 3...8)
                let r4 = Int.random(in: 2...min(15, r2 * r3))
                text = "\(r1) + \(r2) × \(r3) - \(r4)"
                correct = r1 + (r2 * r3) - r4
                distractorCandidates = [(r1 + r2) * r3 - r4, (r1 + r2) * (r3 - r4), r1 + (r2 * (r3 - r4)), correct + 10, correct - 10]
            }
            range = 15
        case .hard:
            let divisor = Int.random(in: 2...6)
            let quotient = Int.random(in: 3...12)
            let dividend = divisor * quotient
            let r1 = Int.random(in: 4...12)
            let r2 = Int.random(in: 3...9)
            let r3 = Int.random(in: 2...10)
            text = "\(r1) × \(r2) + \(dividend) ÷ \(divisor) - \(r3)"
            correct = (r1 * r2) + quotient - r3
            distractorCandidates = [(r1 * r2) + dividend - r3, (r1 * r2) + quotient, (r1 * r2) + quotient + r3, correct + 10, correct - 10, correct + 1, correct - 1]
            range = 20
        case .ultimate:
            if Bool.random() {
                let a = Int.random(in: 3...7)
                let b = Int.random(in: 3...8)
                let c = Int.random(in: 2...8)
                let d = Int.random(in: 2...15)
                text = "\(a)² + \(b) × \(c) - \(d)"
                correct = (a * a) + (b * c) - d
                distractorCandidates = [(a + b) * (a + b) * c - d, (a * a + b) * c - d, (a * a) + (b * (c - d)), correct + 10, correct - 10, correct + 1]
            } else {
                let a = Int.random(in: 2...10)
                let b = Int.random(in: 2...5)
                let c = Int.random(in: 2...6)
                let d = Int.random(in: 2...15)
                text = "(\(a) + \(b)²) × \(c) - \(d)"
                correct = (a + b * b) * c - d
                distractorCandidates = [a + (b * b * c) - d, ((a + b) * (a + b)) * c - d, (a + b * b) * (c - d), correct + 10, correct - 10]
            }
            range = 25
        case .godlike:
            let d = Int.random(in: 2...6)
            let innerResult = Int.random(in: 3...8)
            let targetInner = d * innerResult
            let a = Int.random(in: 4...9)
            let minB = (targetInner / a) + 1
            let b = Int.random(in: max(4, minB)...max(minB + 2, 9))
            let c = (a * b) - targetInner
            let e = Int.random(in: 2...8)
            let f = Int.random(in: 2...8)
            text = "[(\(a) × \(b) - \(c)) ÷ \(d)]² + \(e) × \(f)"
            correct = (innerResult * innerResult) + (e * f)
            distractorCandidates = [innerResult + (e * f), (innerResult * innerResult) + e + f, targetInner + (e * f), correct + 10, correct - 10, correct + 20, correct - 20]
            range = 30
        }

        let options = makeNumericOptions(correct: correct, range: range, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_operator_precedence", comment: "Operator precedence"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 6. Sequences
    private func generateSequences(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let seq: [Int]
        let missingPos: Int

        switch level {
        case .beginner:
            let start = Int.random(in: 1...10)
            let step = Int.random(in: 1...3)
            seq = [start, start + step, start + 2 * step, start + 3 * step]
            missingPos = Int.random(in: 0...3)
        case .easy:
            let start = Int.random(in: 15...40)
            let step = Int.random(in: 4...9)
            if Bool.random() {
                seq = [start, start + step, start + 2 * step, start + 3 * step]
            } else {
                seq = [start, start - step, start - 2 * step, start - 3 * step]
            }
            missingPos = Int.random(in: 0...3)
        case .medium:
            if Bool.random() {
                let start = Int.random(in: 2...5)
                let ratio = Int.random(in: 2...3)
                seq = [start, start * ratio, start * ratio * ratio, start * ratio * ratio * ratio]
            } else {
                let base = Int.random(in: 2...6)
                seq = [base * base, (base + 1) * (base + 1), (base + 2) * (base + 2), (base + 3) * (base + 3)]
            }
            missingPos = Int.random(in: 0...3)
        case .hard:
            if Bool.random() {
                let a1 = Int.random(in: 2...5)
                let a2 = Int.random(in: 3...7)
                let a3 = a1 + a2
                let a4 = a2 + a3
                let a5 = a3 + a4
                seq = [a1, a2, a3, a4, a5]
                missingPos = Int.random(in: 2...4)
            } else {
                let start = Int.random(in: 10...30)
                let stepAdd = Int.random(in: 5...10)
                let stepSub = Int.random(in: 2...4)
                let s0 = start
                let s1 = s0 + stepAdd
                let s2 = s1 - stepSub
                let s3 = s2 + stepAdd
                let s4 = s3 - stepSub
                seq = [s0, s1, s2, s3, s4]
                missingPos = Int.random(in: 1...4)
            }
        case .ultimate:
            let start = Int.random(in: 2...12)
            let diffStart = Int.random(in: 2...4)
            let diffStep = Int.random(in: 2...3)
            let e0 = start
            let e1 = e0 + diffStart
            let e2 = e1 + (diffStart + diffStep)
            let e3 = e2 + (diffStart + 2 * diffStep)
            let e4 = e3 + (diffStart + 3 * diffStep)
            seq = [e0, e1, e2, e3, e4]
            missingPos = Int.random(in: 1...4)
        case .godlike:
            if Bool.random() {
                let startA = Int.random(in: 2...10)
                let stepA = Int.random(in: 2...5)
                let startB = Int.random(in: 40...70)
                let stepB = Int.random(in: 3...6)
                seq = [
                    startA, startB,
                    startA + stepA, startB - stepB,
                    startA + 2 * stepA, startB - 2 * stepB
                ]
                missingPos = [3, 4, 5].randomElement() ?? 5
            } else {
                let s = Int.random(in: 2...5)
                let e0 = s
                let e1 = 2 * e0 - 1
                let e2 = 2 * e1 - 1
                let e3 = 2 * e2 - 1
                let e4 = 2 * e3 - 1
                seq = [e0, e1, e2, e3, e4]
                missingPos = Int.random(in: 2...4)
            }
        }

        let correct = seq[missingPos]
        var distractorCandidates: [Int] = [
            correct + 1, correct - 1, correct + 2, correct - 2,
            correct + 10, correct - 10
        ]
        if missingPos > 0 {
            distractorCandidates.append(seq[missingPos - 1])
        }
        if missingPos + 1 < seq.count {
            distractorCandidates.append(seq[missingPos + 1])
        }
        if seq.count >= 2 {
            let diff = abs(seq[1] - seq[0])
            distractorCandidates.append(contentsOf: [correct + diff, correct - diff, correct + 2 * diff])
        }

        var textParts: [String] = []
        for i in 0..<seq.count {
            if i == missingPos {
                textParts.append("?")
            } else {
                textParts.append("\(seq[i])")
            }
        }

        let text = textParts.joined(separator: ", ")
        let options = makeNumericOptions(correct: correct, range: 12, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_missing_seq", comment: "Missing sequence number"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 7. Equations
    private func generateEquations(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let text: String
        let correctX: Int
        let range: Int
        var distractorCandidates: [Int] = []

        switch level {
        case .beginner:
            let a = Int.random(in: 3...12)
            let x = Int.random(in: 4...20)
            if Bool.random() {
                let b = x + a
                text = "x + \(a) = \(b)"
            } else {
                let b = x - a
                text = "x - \(a) = \(b)"
            }
            correctX = x
            range = 8
            distractorCandidates = [correctX + a, correctX - a, a, correctX + 1, correctX - 1]
        case .easy:
            let a = Int.random(in: 2...6)
            let x = Int.random(in: 2...9)
            let b = Int.random(in: 2...15)
            let c = (a * x) + b
            text = "\(a)x + \(b) = \(c)"
            correctX = x
            range = 8
            distractorCandidates = [c - b, (c + b) / max(1, a), a, b, correctX + 1, correctX - 1]
        case .medium:
            let a = Int.random(in: 2...8)
            let b = Int.random(in: 2...6)
            let c = Int.random(in: 2...10)
            correctX = (b * a) + c
            text = "y = \(a);  x = \(b)y + \(c)"
            range = 10
            distractorCandidates = [a, b * a, (b + c) * a, correctX + 1, correctX - 1, correctX + 10]
        case .hard:
            let x = Int.random(in: 6...25)
            let y = Int.random(in: 2...min(20, x - 1))
            let sum = x + y
            let diff = x - y
            text = "x + y = \(sum);  x - y = \(diff)"
            correctX = x
            range = 10
            distractorCandidates = [y, sum, diff, (sum + diff), correctX + 1, correctX - 1]
        case .ultimate:
            let x = Int.random(in: 4...20)
            let y = Int.random(in: 2...15)
            let c1 = (2 * x) + y
            let c2 = x - y
            text = "2x + y = \(c1);  x - y = \(c2)"
            correctX = x
            range = 10
            distractorCandidates = [y, c1 - c2, c1, c2, correctX + 1, correctX - 1, correctX + 2]
        case .godlike:
            if Bool.random() {
                let z = Int.random(in: 2...6)
                let d = Int.random(in: 2...8)
                let e = Int.random(in: 2...10)
                let y = (2 * z) + d
                correctX = y + (2 * z) + e
                text = "z = \(z);  y = 2z + \(d);  x = y + 2z + \(e)"
                distractorCandidates = [y, z, correctX - e, correctX - d, correctX + 1, correctX - 1, correctX + 10]
            } else {
                let r1 = Int.random(in: 2...6)
                let r2 = Int.random(in: 7...12)
                let p = r1 + r2
                let q = r1 * r2
                text = "x² - \(p)x + \(q) = 0   (x > \(r1))"
                correctX = r2
                distractorCandidates = [r1, p, q, r2 + 1, r2 - 1, p - r1]
            }
            range = 10
        }

        let options = makeNumericOptions(correct: correctX, range: range, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(correctX)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_find_x", comment: "Find value of x"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 8. Memory Addition
    private func generateMemoryAdd(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let stepCount: Int
        switch level {
        case .beginner:
            stepCount = 3
        case .easy:
            stepCount = (questionIndex < 8) ? 4 : 5
        case .medium:
            stepCount = 5 + (questionIndex / 5)
        case .hard:
            stepCount = 7 + (questionIndex / 5)
        case .ultimate:
            stepCount = 10 + Int(Double(questionIndex) * 5.0 / 14.0)
        case .godlike:
            stepCount = 8 + Int(round(Double(questionIndex) * 15.0 / 14.0)) // 8..23!
        }

        let first = Int.random(in: 2...12)
        var steps = ["\(first)"]
        var currentSum = first
        var lastAddedVal: Int? = nil
        var history = [first]

        for _ in 1..<stepCount {
            var nextVal = Int.random(in: 2...10)
            while nextVal == lastAddedVal {
                nextVal = Int.random(in: 2...10)
            }
            lastAddedVal = nextVal
            currentSum += nextVal
            history.append(currentSum)
            steps.append("+\(nextVal)")
        }

        let penultimate = history.count >= 2 ? history[history.count - 2] : currentSum - 2
        let antepenultimate = history.count >= 3 ? history[history.count - 3] : currentSum + 2
        let distractorCandidates = [penultimate, antepenultimate, currentSum + 1, currentSum - 1, currentSum + 2, currentSum - 2, currentSum + 10, currentSum - 10]
        let options = makeNumericOptions(correct: currentSum, range: 10, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(currentSum)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 9. Memory Add & Subtract
    private func generateMemoryAddSub(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let stepCount: Int
        switch level {
        case .beginner:
            stepCount = 3
        case .easy:
            stepCount = (questionIndex < 8) ? 4 : 5
        case .medium:
            stepCount = 5 + (questionIndex / 5)
        case .hard:
            stepCount = 7 + (questionIndex / 5)
        case .ultimate:
            stepCount = 10 + Int(Double(questionIndex) * 5.0 / 14.0)
        case .godlike:
            stepCount = 8 + Int(round(Double(questionIndex) * 15.0 / 14.0)) // 8..23!
        }

        let first = Int.random(in: 10...25)
        var steps = ["\(first)"]
        var currentVal = first
        var lastStepString: String? = nil
        var history = [first]

        for _ in 1..<stepCount {
            let isAdd: Bool
            if currentVal <= 2 {
                isAdd = true
            } else {
                isAdd = Bool.random()
            }

            var delta: Int
            var stepString: String

            if isAdd {
                delta = Int.random(in: 2...10)
                stepString = "+\(delta)"
                while stepString == lastStepString {
                    delta = Int.random(in: 2...10)
                    stepString = "+\(delta)"
                }
                currentVal += delta
            } else {
                let maxSub = min(10, currentVal - 1)
                if maxSub >= 2 {
                    delta = Int.random(in: 2...maxSub)
                } else {
                    delta = 1
                }
                stepString = "-\(delta)"
                if stepString == lastStepString {
                    let availableDeltas = (2...max(2, maxSub)).filter { "-\($0)" != lastStepString }
                    if let newDelta = availableDeltas.randomElement() {
                        delta = newDelta
                        stepString = "-\(delta)"
                        currentVal -= delta
                    } else {
                        delta = Int.random(in: 2...10)
                        stepString = "+\(delta)"
                        currentVal += delta
                    }
                } else {
                    currentVal -= delta
                }
            }

            lastStepString = stepString
            history.append(currentVal)
            steps.append(stepString)
        }

        let penultimate = history.count >= 2 ? history[history.count - 2] : currentVal - 2
        let antepenultimate = history.count >= 3 ? history[history.count - 3] : currentVal + 2
        let distractorCandidates = [penultimate, antepenultimate, currentVal + 1, currentVal - 1, currentVal + 2, currentVal - 2, currentVal + 10, currentVal - 10]
        let options = makeNumericOptions(correct: currentVal, range: 10, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(currentVal)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 10. Memory Math Operations
    private func generateMemoryAddSubMult(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let stepCount: Int
        switch level {
        case .beginner:
            stepCount = 3
        case .easy:
            stepCount = (questionIndex < 8) ? 4 : 5
        case .medium:
            stepCount = 5 + (questionIndex / 5)
        case .hard:
            stepCount = 7 + (questionIndex / 5)
        case .ultimate:
            stepCount = 10 + Int(Double(questionIndex) * 5.0 / 14.0)
        case .godlike:
            stepCount = 8 + Int(round(Double(questionIndex) * 15.0 / 14.0)) // 8..23!
        }

        let first = Int.random(in: 2...8)
        var steps = ["\(first)"]
        var currentVal = first
        var lastStepString: String? = nil
        var history = [first]

        for i in 1..<stepCount {
            var opString = ""
            var attempts = 0
            while attempts < 20 {
                attempts += 1
                let choice: Int
                if i == 1 && Bool.random() {
                    choice = 0
                } else if currentVal <= 2 {
                    choice = 1
                } else {
                    choice = Int.random(in: 0...2)
                }

                var tempVal = currentVal
                var candidateStr = ""

                switch choice {
                case 0:
                    let mult = Int.random(in: 2...4)
                    candidateStr = "×\(mult)"
                    tempVal *= mult
                case 1:
                    let delta = Int.random(in: 2...8)
                    candidateStr = "+\(delta)"
                    tempVal += delta
                default:
                    let maxSub = min(8, currentVal - 1)
                    if maxSub >= 2 {
                        let delta = Int.random(in: 2...maxSub)
                        candidateStr = "-\(delta)"
                        tempVal -= delta
                    } else {
                        candidateStr = "-1"
                        tempVal -= 1
                    }
                }

                if candidateStr != lastStepString && tempVal >= 1 {
                    opString = candidateStr
                    currentVal = tempVal
                    break
                }
            }

            if opString.isEmpty {
                var delta = Int.random(in: 2...8)
                while "+\(delta)" == lastStepString {
                    delta += 1
                }
                opString = "+\(delta)"
                currentVal += delta
            }

            lastStepString = opString
            history.append(currentVal)
            steps.append(opString)
        }

        let penultimate = history.count >= 2 ? history[history.count - 2] : currentVal - 2
        let antepenultimate = history.count >= 3 ? history[history.count - 3] : currentVal + 2
        let distractorCandidates = [penultimate, antepenultimate, currentVal + 1, currentVal - 1, currentVal + 2, currentVal - 2, currentVal + 10, currentVal - 10]
        let options = makeNumericOptions(correct: currentVal, range: 12, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(currentVal)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 11. Memory Shapes (ALL figures in SAME uniform color)
    private func generateMemoryShapes(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let shapes = ["square.fill", "circle.fill", "triangle.fill", "diamond.fill", "star.fill"]
        let targetShape = shapes.randomElement() ?? "circle.fill"
        
        let uniformColor = ["BLUE", "PURPLE", "ORANGE", "GREEN"].randomElement() ?? "BLUE"

        let gridCount: Int
        let previewSecs: Double
        switch level {
        case .beginner: gridCount = 6; previewSecs = 6.0
        case .easy: gridCount = 8; previewSecs = 7.0
        case .medium: gridCount = 10; previewSecs = 8.0
        case .hard: gridCount = 14; previewSecs = 8.0
        case .ultimate: gridCount = 18; previewSecs = 7.5
        case .godlike:
            gridCount = 20 + min(4, questionIndex / 3) // 20..24
            previewSecs = 6.5
        }

        var items: [MemoryGridItem] = []
        var targetCount = 0
        for _ in 0..<gridCount {
            if let shape = shapes.randomElement() {
                items.append(MemoryGridItem(shapeSymbol: shape, colorName: uniformColor))
                if shape == targetShape {
                    targetCount += 1
                }
            }
        }

        let shapeNameKey: String
        switch targetShape {
        case "square.fill": shapeNameKey = "shape_squares"
        case "circle.fill": shapeNameKey = "shape_circles"
        case "triangle.fill": shapeNameKey = "shape_triangles"
        case "diamond.fill": shapeNameKey = "shape_diamonds"
        default: shapeNameKey = "shape_stars"
        }

        var shapeCounts: [String: Int] = [:]
        for item in items {
            shapeCounts[item.shapeSymbol, default: 0] += 1
        }
        let otherShapeCounts = shapeCounts.filter { $0.key != targetShape }.map { $0.value }
        let distractorCandidates = otherShapeCounts + [
            gridCount - targetCount,
            targetCount + 1, targetCount - 1,
            targetCount + 2, targetCount - 2
        ]

        let options = makeNumericOptions(correct: targetCount, range: 4, minVal: 0, maxVal: gridCount, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(targetCount)") ?? 0

        let localizedShapeName = NSLocalizedString(shapeNameKey, comment: "Shape name")
        let formatStr = NSLocalizedString("prompt_memory_shapes_count_format", comment: "How many shapes")
        let promptText = String(format: formatStr, localizedShapeName)

        return Question(
            text: promptText,
            subtext: NSLocalizedString("prompt_memory_shapes_subtext", comment: "Memorize grid"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: items,
            memoryPreviewSeconds: previewSecs
        )
    }

    // MARK: - 12. Memory Colors (Figures in DIFFERENT vibrant colors)
    private func generateMemoryColors(level: GameLevel, maxTime: Double, questionIndex: Int = 0) -> Question {
        let colors = ["RED", "BLUE", "GREEN", "YELLOW", "PURPLE", "ORANGE"]
        let targetColor = colors.randomElement() ?? "RED"
        let shapes = ["square.fill", "circle.fill", "triangle.fill", "star.fill"]

        let gridCount: Int
        let previewSecs: Double
        switch level {
        case .beginner: gridCount = 6; previewSecs = 6.0
        case .easy: gridCount = 8; previewSecs = 7.0
        case .medium: gridCount = 10; previewSecs = 8.0
        case .hard: gridCount = 14; previewSecs = 8.0
        case .ultimate: gridCount = 18; previewSecs = 7.5
        case .godlike:
            gridCount = 20 + min(4, questionIndex / 3) // 20..24
            previewSecs = 6.5
        }

        var items: [MemoryGridItem] = []
        var targetCount = 0
        for _ in 0..<gridCount {
            if let color = colors.randomElement(), let shape = shapes.randomElement() {
                items.append(MemoryGridItem(shapeSymbol: shape, colorName: color))
                if color == targetColor {
                    targetCount += 1
                }
            }
        }

        var colorCounts: [String: Int] = [:]
        for item in items {
            colorCounts[item.colorName, default: 0] += 1
        }
        let otherColorCounts = colorCounts.filter { $0.key != targetColor }.map { $0.value }
        let distractorCandidates = otherColorCounts + [
            gridCount - targetCount,
            targetCount + 1, targetCount - 1,
            targetCount + 2, targetCount - 2
        ]

        let options = makeNumericOptions(correct: targetCount, range: 4, minVal: 0, maxVal: gridCount, contextCandidates: distractorCandidates)
        let correctIdx = options.firstIndex(of: "\(targetCount)") ?? 0

        let colorKey: String
        switch targetColor {
        case "RED": colorKey = "color_red"
        case "BLUE": colorKey = "color_blue"
        case "GREEN": colorKey = "color_green"
        case "YELLOW": colorKey = "color_yellow"
        case "PURPLE": colorKey = "color_purple"
        case "ORANGE": colorKey = "color_orange"
        default: colorKey = "color_red"
        }

        let localizedColorName = NSLocalizedString(colorKey, comment: "Color name")
        let formatStr = NSLocalizedString("prompt_memory_colors_count_format", comment: "How many color items")
        let promptText = String(format: formatStr, localizedColorName)

        return Question(
            text: promptText,
            subtext: NSLocalizedString("prompt_memory_colors_subtext", comment: "Memorize colors grid"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: items,
            memoryPreviewSeconds: previewSecs
        )
    }

    // MARK: - 13. Chemistry Symbols
    private func generateChemSymbols(level: GameLevel, maxTime: Double) -> Question {
        let idx = selectElementIndex(level: level)
        let targetElem = allElements[idx]
        let rawOptions = pickChemSymbolDistractors(targetElem: targetElem, level: level)
        let localizedTarget = localizedElementName(for: targetElem.name)
        let localizedOptions = rawOptions.map { localizedElementName(for: $0) }
        let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

        return Question(
            text: targetElem.symbol,
            subtext: NSLocalizedString("prompt_chem_symbol", comment: "Which element symbol"),
            options: localizedOptions,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 14. Chemistry Names
    private func generateChemNames(level: GameLevel, maxTime: Double) -> Question {
        let idx = selectElementIndex(level: level)
        let targetElem = allElements[idx]
        let options = pickChemNameDistractors(targetElem: targetElem, level: level)
        let correctIdx = options.firstIndex(of: targetElem.symbol) ?? 0
        let localizedTargetName = localizedElementName(for: targetElem.name)

        return Question(
            text: localizedTargetName,
            subtext: NSLocalizedString("prompt_chem_name", comment: "What is symbol"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 15. Flags
    private func generateFlags(level: GameLevel, maxTime: Double) -> Question {
        let totalCount = allCountries.count
        guard totalCount > 0 else {
            let target = localizedCountryName(for: "Poland")
            return Question(
                text: target,
                subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
                options: [localizedCountryName(for: "Poland"), localizedCountryName(for: "Germany"), localizedCountryName(for: "France"), localizedCountryName(for: "Italy")],
                correctIndex: 0,
                maxTime: maxTime,
                flagImageName: "Poland",
                memorySteps: nil,
                memoryGridItems: nil,
                memoryPreviewSeconds: nil
            )
        }

        let countryIndex: Int
        switch level {
        case .beginner:
            countryIndex = Int.random(in: 0..<min(25, totalCount))
        case .easy:
            countryIndex = Int.random(in: 0..<min(55, totalCount))
        case .medium:
            countryIndex = Int.random(in: min(25, totalCount - 1)..<min(80, totalCount))
        case .hard:
            countryIndex = Int.random(in: min(50, totalCount - 1)..<min(120, totalCount))
        case .ultimate:
            countryIndex = Int.random(in: min(80, totalCount - 1)..<min(160, totalCount))
        case .godlike:
            countryIndex = Int.random(in: min(100, totalCount - 1)..<totalCount)
        }

        let rawTargetCountry = allCountries[countryIndex]
        let flagAssetName = rawTargetCountry.replacingOccurrences(of: " ", with: "_")
        let rawOptions = pickCountryDistractors(targetCountry: rawTargetCountry, level: level)
        let localizedTarget = localizedCountryName(for: rawTargetCountry)
        let localizedOptions = rawOptions.map { localizedCountryName(for: $0) }
        let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

        return Question(
            text: localizedTarget,
            subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
            options: localizedOptions,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: flagAssetName,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 16. Capitals (Countries - Cities)
    private func generateCapitals(level: GameLevel, maxTime: Double) -> Question {
        let pool = capitalsPool(for: level)
        let targetCountry = pool.randomElement() ?? "Poland"
        return makeCapitalQuestion(
            targetCountry: targetCountry,
            level: level,
            maxTime: maxTime,
            askForCapital: Bool.random()
        )
    }

    func makeCapitalQuestion(
        targetCountry: String,
        level: GameLevel,
        maxTime: Double,
        askForCapital: Bool
    ) -> Question {
        let capital = capitalCity(for: targetCountry)
        let itemKey = "city_\(capital)"

        if askForCapital {
            // Direction A: Ask for the capital of the country (Options = 4 cities)
            let rawCityOptions = pickCityDistractors(targetCountry: targetCountry, level: level)
            let localizedTargetCity = localizedCityName(for: capital)
            let localizedOptions = rawCityOptions.map { localizedCityName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTargetCity) ?? 0

            return Question(
                itemKey: itemKey,
                text: localizedCountryName(for: targetCountry),
                subtext: NSLocalizedString("prompt_country_to_capital", comment: "What is the capital of this country?"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            // Direction B: Ask which country has this capital (Options = 4 countries)
            let rawCountryOptions = pickCapitalCountryDistractors(targetCountry: targetCountry, level: level)
            let localizedTargetCountry = localizedCountryName(for: targetCountry)
            let localizedOptions = rawCountryOptions.map { localizedCountryName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTargetCountry) ?? 0

            return Question(
                itemKey: itemKey,
                text: localizedCityName(for: capital),
                subtext: NSLocalizedString("prompt_capital_to_country", comment: "Which country is this the capital of?"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func pickCityDistractors(targetCountry: String, level: GameLevel) -> [String] {
        let countryCityList = cities(for: targetCountry)
        let capital = countryCityList.first ?? targetCountry
        var choices: [String] = [capital]
        var usedLocalized = Set<String>([localizedCityName(for: capital)])

        func tryAddCity(_ city: String) -> Bool {
            let loc = localizedCityName(for: city)
            guard !choices.contains(city) && !usedLocalized.contains(loc) else { return false }
            choices.append(city)
            usedLocalized.insert(loc)
            return true
        }

        // 1. Primary distractors: non-capital largest cities from the SAME country (up to 3 additional cities)
        let sameCountryNonCapitals = Array(countryCityList.dropFirst()).shuffled()
        for city in sameCountryNonCapitals {
            if choices.count >= 4 { break }
            _ = tryAddCity(city)
        }

        // 2. If fewer than 4 choices, fill from regional clusters & level pool capitals/cities
        if choices.count < 4 {
            var regionalCities: [String] = []
            for pool in regionalCountryPools {
                if pool.contains(targetCountry) {
                    for partner in pool where partner != targetCountry {
                        regionalCities.append(contentsOf: cities(for: partner))
                    }
                }
            }
            for city in regionalCities.shuffled() {
                if choices.count >= 4 { break }
                _ = tryAddCity(city)
            }
        }

        if choices.count < 4 {
            let levelCountries = capitalsPool(for: level).filter { $0 != targetCountry }.shuffled()
            for country in levelCountries {
                if choices.count >= 4 { break }
                _ = tryAddCity(capitalCity(for: country))
            }
        }

        while choices.count < 4 {
            if let randCountry = allCountries.randomElement() {
                _ = tryAddCity(capitalCity(for: randCountry))
            }
        }

        return choices.shuffled()
    }

    private func pickCapitalCountryDistractors(targetCountry: String, level: GameLevel) -> [String] {
        var choices: [String] = [targetCountry]
        var usedLocalized = Set<String>([localizedCountryName(for: targetCountry)])

        func tryAddCountry(_ country: String) -> Bool {
            let loc = localizedCountryName(for: country)
            guard !choices.contains(country) && !usedLocalized.contains(loc) else { return false }
            choices.append(country)
            usedLocalized.insert(loc)
            return true
        }

        var regionalCandidates: [String] = []
        for pool in regionalCountryPools {
            if pool.contains(targetCountry) {
                regionalCandidates.append(contentsOf: pool.filter { $0 != targetCountry && allCountries.contains($0) })
            }
        }

        var nameCandidates: [String] = []
        for cluster in similarNameClusters {
            if cluster.contains(targetCountry) {
                nameCandidates.append(contentsOf: cluster.filter { $0 != targetCountry && allCountries.contains($0) })
            }
        }

        let levelCountries = capitalsPool(for: level).filter { $0 != targetCountry }

        let candidatePools: [[String]] = [
            regionalCandidates.shuffled(),
            nameCandidates.shuffled(),
            levelCountries.shuffled()
        ].shuffled()

        for pool in candidatePools {
            if choices.count >= 4 { break }
            for country in pool {
                if tryAddCountry(country) {
                    break
                }
            }
        }

        for country in levelCountries.shuffled() {
            if choices.count >= 4 { break }
            _ = tryAddCountry(country)
        }

        for country in allCountries.shuffled() {
            if choices.count >= 4 { break }
            _ = tryAddCountry(country)
        }

        return choices.shuffled()
    }

    // MARK: - 17. Roman Numerals (1 - 3999 & Arithmetic)
    let romanHardNumbers: [Int] = [
        104, 109, 114, 125, 140, 144, 149, 150, 166, 190,
        194, 199, 200, 222, 240, 249, 250, 275, 290, 299,
        300, 333, 344, 349, 350, 388, 390, 399, 400, 404,
        419, 440, 444, 449, 450, 475, 490, 494, 499, 500
    ]

    let romanUltimateNumbers: [Int] = [
        504, 549, 555, 599, 600, 644, 666, 700, 749, 777,
        800, 844, 888, 900, 944, 949, 990, 994, 999, 1000,
        1024, 1066, 1200, 1337, 1410, 1492, 1500, 1600, 1776, 1888,
        1900, 1918, 1945, 1989, 1999, 2000, 2024, 2026, 3000, 3999
    ]

    var allTrackableRomanNumbers: [Int] {
        return Array(1...100) + romanHardNumbers + romanUltimateNumbers
    }

    func toRoman(_ number: Int) -> String {
        guard number >= 1 && number <= 3999 else { return "\(number)" }
        let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        let numerals = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        var remaining = number
        var result = ""
        for (idx, val) in values.enumerated() {
            while remaining >= val {
                result += numerals[idx]
                remaining -= val
            }
        }
        return result
    }

    func romanPool(for level: GameLevel) -> [Int] {
        switch level {
        case .beginner: return Array(1...20)
        case .easy: return Array(1...50)
        case .medium: return Array(1...100)
        case .hard: return romanHardNumbers
        case .ultimate: return romanUltimateNumbers
        case .godlike: return []
        }
    }

    private func makeRomanOptions(for number: Int, maxRange: Int = 3999) -> [String] {
        let correct = toRoman(number)
        var set = Set<String>([correct])

        var mistakeCandidates: [String] = []
        let replacements: [(String, String)] = [
            ("IV", "IIII"),
            ("IX", "VIIII"),
            ("XL", "XXXX"),
            ("XC", "LXXXX"),
            ("CD", "CCCC"),
            ("CM", "DCCCC"),
            ("IV", "VI"),
            ("IX", "XI"),
            ("XL", "LX"),
            ("XC", "CX"),
            ("CD", "DC"),
            ("CM", "MC")
        ]
        for (target, bad) in replacements where correct.contains(target) {
            let candidate = correct.replacingOccurrences(of: target, with: bad)
            if candidate != correct && !candidate.isEmpty {
                mistakeCandidates.append(candidate)
            }
        }
        let illegalShortcuts: [Int: String] = [
            45: "VL", 49: "IL", 95: "VC", 99: "IC",
            490: "XD", 499: "ID", 990: "XM", 999: "IM", 1999: "MIM"
        ]
        if let shortcut = illegalShortcuts[number], shortcut != correct {
            mistakeCandidates.append(shortcut)
        }

        // Add 1-2 realistic notation mistakes when available
        for cand in mistakeCandidates.shuffled().prefix(2) {
            set.insert(cand)
        }

        // Fill remaining options with nearby valid Roman numerals
        let offsets = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 10, -10, 20, -20, 50, -50, 100, -100]
        var nearbyNumbers: [Int] = []
        for off in offsets {
            let cand = number + off
            if cand >= 1 && cand <= 3999 && cand != number {
                nearbyNumbers.append(cand)
            }
        }
        for n in nearbyNumbers.shuffled() {
            if set.count >= 4 { break }
            set.insert(toRoman(n))
        }

        // Guaranteed fallback
        var fallback = 1
        while set.count < 4 && fallback <= max(maxRange, 3999) {
            if fallback != number {
                set.insert(toRoman(fallback))
            }
            fallback += 1
        }

        return Array(set).shuffled()
    }

    private func makeRomanQuestion(number: Int, level: GameLevel, maxTime: Double, askArabicToRoman: Bool = Bool.random()) -> Question {
        let roman = toRoman(number)
        let itemKey = "roman_\(number)"
        if askArabicToRoman {
            let options = makeRomanOptions(for: number, maxRange: max(100, number + 50))
            let correctIdx = options.firstIndex(of: roman) ?? 0
            return Question(
                itemKey: itemKey,
                text: "\(number)",
                subtext: NSLocalizedString("prompt_arabic_to_roman", comment: "Write in Roman numerals:"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            let maxVal: Int
            switch level {
            case .beginner: maxVal = 25
            case .easy: maxVal = 60
            case .medium: maxVal = 120
            case .hard: maxVal = 550
            case .ultimate, .godlike: maxVal = 3999
            }
            var context: [Int] = [number + 1, number - 1, number + 2, number - 2, number + 5, number - 5, number + 10, number - 10]
            if number >= 12 {
                context.append(number + 9)
                context.append(number - 9)
            }
            let options = makeNumericOptions(correct: number, range: 15, minVal: 1, maxVal: maxVal, contextCandidates: context)
            let correctIdx = options.firstIndex(of: "\(number)") ?? 0
            return Question(
                itemKey: itemKey,
                text: roman,
                subtext: NSLocalizedString("prompt_roman_to_arabic", comment: "What number is this?"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateRomanNumerals(level: GameLevel, maxTime: Double) -> Question {
        if level == .godlike {
            let opType = Int.random(in: 0...3)
            var a = 0
            var b = 0
            var result = 0
            var expr = ""
            switch opType {
            case 0: // Addition
                a = Int.random(in: 12...450)
                b = Int.random(in: 12...450)
                result = a + b
                expr = "\(toRoman(a)) + \(toRoman(b))"
            case 1: // Subtraction
                b = Int.random(in: 14...250)
                result = Int.random(in: 15...450)
                a = b + result
                expr = "\(toRoman(a)) - \(toRoman(b))"
            case 2: // Multiplication
                a = Int.random(in: 4...25)
                b = Int.random(in: 3...19)
                result = a * b
                expr = "\(toRoman(a)) × \(toRoman(b))"
            default: // Division
                b = Int.random(in: 3...20)
                result = Int.random(in: 4...40)
                a = b * result
                expr = "\(toRoman(a)) ÷ \(toRoman(b))"
            }
            let correctRoman = toRoman(result)
            let options = makeRomanOptions(for: result, maxRange: 3999)
            let correctIdx = options.firstIndex(of: correctRoman) ?? 0
            return Question(
                itemKey: "math_17_\(expr)",
                text: expr,
                subtext: NSLocalizedString("prompt_roman_calc", comment: "Calculate in Roman numerals:"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            let pool = romanPool(for: level)
            let target = pool.randomElement() ?? 1
            return makeRomanQuestion(number: target, level: level, maxTime: maxTime)
        }
    }

    // MARK: - 18. Powers, Roots & Exponents
    let allPowerRootItems: [PowerRootItem] = {
        var items: [PowerRootItem] = []

        // Squares 1...30
        for n in 1...30 {
            let sq = n * n
            items.append(PowerRootItem(
                key: "pow_sq_\(n)",
                expression: "\(n)²",
                answer: "\(sq)",
                numericAnswer: sq,
                contextCandidates: [n * 2, sq + n, max(1, sq - n), (n + 1) * (n + 1), max(1, (n - 1) * (n - 1))],
                distractors: [],
                level: n <= 15 ? .beginner : (n <= 20 ? .easy : .hard)
            ))
        }

        // Square roots √1...√900
        for n in 1...30 {
            let sq = n * n
            items.append(PowerRootItem(
                key: "pow_sqrt_\(n)",
                expression: "√\(sq)",
                answer: "\(n)",
                numericAnswer: n,
                contextCandidates: [n + 1, max(1, n - 1), n + 2, max(1, n - 2), n * 2, max(1, sq / 2)],
                distractors: [],
                level: n <= 10 ? .beginner : (n <= 20 ? .easy : .hard)
            ))
        }

        // Cubes 1³...15³
        for n in 1...15 {
            let cube = n * n * n
            items.append(PowerRootItem(
                key: "pow_cube_\(n)",
                expression: "\(n)³",
                answer: "\(cube)",
                numericAnswer: cube,
                contextCandidates: [n * 3, n * n, cube + n * n, max(1, cube - n * n), (n + 1) * (n + 1) * (n + 1)],
                distractors: [],
                level: n <= 10 ? .medium : .ultimate
            ))
        }

        // Cube roots ∛1...∛3375
        for n in 1...15 {
            let cube = n * n * n
            items.append(PowerRootItem(
                key: "pow_cbrt_\(n)",
                expression: "∛\(cube)",
                answer: "\(n)",
                numericAnswer: n,
                contextCandidates: [n + 1, max(1, n - 1), n + 2, max(1, n - 2), n * 2, n * n],
                distractors: [],
                level: n <= 10 ? .medium : .ultimate
            ))
        }

        // Powers of 2: 2⁰...2¹⁰
        for e in 0...10 {
            let val = 1 << e
            items.append(PowerRootItem(
                key: "pow_2_\(e)",
                expression: "2\(QuestionGenerator.superscriptDigits(e))",
                answer: "\(val)",
                numericAnswer: val,
                contextCandidates: [max(1, 2 * e), max(1, val / 2), val * 2, val + 2, max(1, val - 2)],
                distractors: [],
                level: .medium
            ))
        }

        // Powers of 3: 3¹...3⁵
        var p3 = 1
        for e in 1...5 {
            p3 *= 3
            items.append(PowerRootItem(
                key: "pow_3_\(e)",
                expression: "3\(QuestionGenerator.superscriptDigits(e))",
                answer: "\(p3)",
                numericAnswer: p3,
                contextCandidates: [3 * e, max(1, p3 / 3), p3 * 3, p3 + 3, max(1, p3 - 3)],
                distractors: [],
                level: .hard
            ))
        }

        // Powers of 4: 4¹...4⁴
        var p4 = 1
        for e in 1...4 {
            p4 *= 4
            items.append(PowerRootItem(
                key: "pow_4_\(e)",
                expression: "4\(QuestionGenerator.superscriptDigits(e))",
                answer: "\(p4)",
                numericAnswer: p4,
                contextCandidates: [4 * e, max(1, p4 / 4), p4 * 2, p4 + 4, max(1, p4 - 4)],
                distractors: [],
                level: .hard
            ))
        }

        // Powers of 5: 5¹...5⁴
        var p5 = 1
        for e in 1...4 {
            p5 *= 5
            items.append(PowerRootItem(
                key: "pow_5_\(e)",
                expression: "5\(QuestionGenerator.superscriptDigits(e))",
                answer: "\(p5)",
                numericAnswer: p5,
                contextCandidates: [5 * e, max(1, p5 / 5), p5 * 5, p5 + 25, max(1, p5 - 25)],
                distractors: [],
                level: .hard
            ))
        }

        // Powers of 10: 10¹...10⁶
        var p10 = 1
        for e in 1...6 {
            p10 *= 10
            items.append(PowerRootItem(
                key: "pow_10_\(e)",
                expression: "10\(QuestionGenerator.superscriptDigits(e))",
                answer: "\(p10)",
                numericAnswer: p10,
                contextCandidates: [10 * e, max(10, p10 / 10), p10 * 10, p10 * 100, max(1, p10 / 100)],
                distractors: [],
                level: .hard
            ))
        }

        // Ultimate: 0 and negative exponents + 4th powers (2⁴...6⁴)
        let ultimateSpecials: [(String, String, String, [String])] = [
            ("pow_zero_5", "5⁰", "1", ["0", "5", "0.2", "-1"]),
            ("pow_zero_10", "10⁰", "1", ["0", "10", "0.1", "100"]),
            ("pow_neg_2_1", "2⁻¹", "0.5", ["-2", "0.2", "0.25", "2"]),
            ("pow_neg_2_2", "2⁻²", "0.25", ["-4", "0.5", "0.125", "0.2"]),
            ("pow_neg_2_3", "2⁻³", "0.125", ["-8", "0.25", "0.0625", "0.375"]),
            ("pow_neg_4_1", "4⁻¹", "0.25", ["-4", "0.4", "0.5", "0.125"]),
            ("pow_neg_5_1", "5⁻¹", "0.2", ["-5", "0.5", "0.05", "0.25"]),
            ("pow_neg_5_2", "5⁻²", "0.04", ["-25", "0.2", "0.02", "0.4"]),
            ("pow_neg_10_1", "10⁻¹", "0.1", ["-10", "0.01", "1", "0.5"]),
            ("pow_neg_10_2", "10⁻²", "0.01", ["-100", "0.1", "0.001", "0.02"]),
            ("pow_neg_10_3", "10⁻³", "0.001", ["-1000", "0.01", "0.0001", "0.1"])
        ]
        for (k, expr, ans, dist) in ultimateSpecials {
            items.append(PowerRootItem(
                key: k,
                expression: expr,
                answer: ans,
                numericAnswer: nil,
                contextCandidates: [],
                distractors: dist,
                level: .ultimate
            ))
        }

        for b in 2...6 {
            let val = b * b * b * b
            items.append(PowerRootItem(
                key: "pow_4th_\(b)",
                expression: "\(b)⁴",
                answer: "\(val)",
                numericAnswer: val,
                contextCandidates: [b * 4, b * b * b, val + b * b, max(1, val - b * b), (b + 1) * (b + 1) * (b + 1)],
                distractors: [],
                level: .ultimate
            ))
        }

        return items
    }()

    private static func superscriptDigits(_ n: Int) -> String {
        let map: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹", "-": "⁻"
        ]
        return String("\(n)".map { map[$0] ?? $0 })
    }

    func powerRootPool(for level: GameLevel) -> [PowerRootItem] {
        switch level {
        case .beginner:
            return allPowerRootItems.filter { item in
                (item.key.hasPrefix("pow_sq_") && (Int(item.key.replacingOccurrences(of: "pow_sq_", with: "")) ?? 99) <= 15) ||
                (item.key.hasPrefix("pow_sqrt_") && (Int(item.key.replacingOccurrences(of: "pow_sqrt_", with: "")) ?? 99) <= 10)
            }
        case .easy:
            return allPowerRootItems.filter { item in
                (item.key.hasPrefix("pow_sq_") && (Int(item.key.replacingOccurrences(of: "pow_sq_", with: "")) ?? 99) <= 20) ||
                (item.key.hasPrefix("pow_sqrt_") && (Int(item.key.replacingOccurrences(of: "pow_sqrt_", with: "")) ?? 99) <= 20)
            }
        case .medium:
            return allPowerRootItems.filter { $0.level == .medium }
        case .hard:
            return allPowerRootItems.filter { $0.level == .hard }
        case .ultimate:
            return allPowerRootItems.filter { $0.level == .ultimate }
        case .godlike:
            return []
        }
    }

    private func makePowerRootQuestion(from item: PowerRootItem, maxTime: Double) -> Question {
        let options: [String]
        if let numAns = item.numericAnswer {
            options = makeNumericOptions(
                correct: numAns,
                range: max(10, numAns / 5),
                minVal: 1,
                contextCandidates: item.contextCandidates
            )
        } else {
            options = makeStringOptions(correct: item.answer, distractors: item.distractors)
        }
        let correctIdx = options.firstIndex(of: item.answer) ?? 0
        return Question(
            itemKey: item.key,
            text: item.expression,
            subtext: NSLocalizedString("prompt_powers_calc", comment: "Calculate the value:"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime
        )
    }

    private func generatePowersRoots(level: GameLevel, maxTime: Double) -> Question {
        if level == .godlike {
            let pattern = Int.random(in: 0...4)
            var expr = ""
            var result = 0
            var context: [Int] = []

            switch pattern {
            case 0:
                let a = Int.random(in: 3...12)
                let b = Int.random(in: 3...12)
                result = a * a + b * b
                expr = "\(a)² + \(b)²"
                context = [2 * a + 2 * b, (a + b) * (a + b), a * a + b, abs(a * a - b * b)]
            case 1:
                let a = Int.random(in: 5...15)
                let c = Int.random(in: 2...min(12, a * a - 1))
                result = a * a - c
                expr = "\(a)² - √\(c * c)"
                context = [a * a + c, a * a - c * c, 2 * a - c, (a - 1) * (a - 1) - c]
            case 2:
                let n = Int.random(in: 3...8)
                let b = Int.random(in: 2...6)
                let p2 = 1 << n
                result = p2 + b * b * b
                expr = "2\(QuestionGenerator.superscriptDigits(n)) + \(b)³"
                context = [2 * n + 3 * b, p2 + b * b, p2 - b * b, (1 << (n - 1)) + b * b * b]
            case 3:
                let a = Int.random(in: 2...10)
                let b = Int.random(in: 2...6)
                result = a * b * b
                expr = "√\(a * a) × \(b)²"
                context = [a * a * b * b, a * 2 * b, a + b * b, (a + 1) * b * b]
            default:
                let a = Int.random(in: 3...8)
                let b = Int.random(in: 2...min(9, Int(sqrt(Double(a * a * a)))))
                result = a * a * a - b * b
                expr = "\(a)³ - \(b)²"
                context = [a * a * a + b * b, a * a - b * b, 3 * a - 2 * b, a * a * a - 2 * b]
            }

            let options = makeNumericOptions(correct: result, range: 25, minVal: 0, contextCandidates: context)
            let correctIdx = options.firstIndex(of: "\(result)") ?? 0
            return Question(
                itemKey: "math_18_\(expr)",
                text: expr,
                subtext: NSLocalizedString("prompt_powers_calc", comment: "Calculate the value:"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            let pool = powerRootPool(for: level)
            guard let item = pool.randomElement() else {
                return Question(text: "2²", options: ["2", "4", "6", "8"], correctIndex: 1, maxTime: maxTime)
            }
            return makePowerRootQuestion(from: item, maxTime: maxTime)
        }
    }

    // MARK: - 19. Fractions, Decimals & Percentages
    let allFractionItems: [FractionProgressItemData] = [
        // Beginner (25): Halves, quarters, fifths, tenths -> % and decimals
        FractionProgressItemData(key: "frac_b_0", expression: "1/2 → %", questionText: "1/2 = ? (%)", subtextKey: "prompt_frac_convert", answer: "50%", distractors: ["25%", "20%", "40%", "75%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_1", expression: "1/4 → %", questionText: "1/4 = ? (%)", subtextKey: "prompt_frac_convert", answer: "25%", distractors: ["50%", "20%", "40%", "15%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_2", expression: "3/4 → %", questionText: "3/4 = ? (%)", subtextKey: "prompt_frac_convert", answer: "75%", distractors: ["25%", "60%", "80%", "70%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_3", expression: "1/5 → %", questionText: "1/5 = ? (%)", subtextKey: "prompt_frac_convert", answer: "20%", distractors: ["25%", "10%", "15%", "50%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_4", expression: "2/5 → %", questionText: "2/5 = ? (%)", subtextKey: "prompt_frac_convert", answer: "40%", distractors: ["20%", "25%", "50%", "60%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_5", expression: "3/5 → %", questionText: "3/5 = ? (%)", subtextKey: "prompt_frac_convert", answer: "60%", distractors: ["30%", "50%", "75%", "40%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_6", expression: "4/5 → %", questionText: "4/5 = ? (%)", subtextKey: "prompt_frac_convert", answer: "80%", distractors: ["75%", "45%", "60%", "90%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_7", expression: "1/10 → %", questionText: "1/10 = ? (%)", subtextKey: "prompt_frac_convert", answer: "10%", distractors: ["1%", "20%", "5%", "25%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_8", expression: "3/10 → %", questionText: "3/10 = ? (%)", subtextKey: "prompt_frac_convert", answer: "30%", distractors: ["3%", "25%", "40%", "35%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_9", expression: "7/10 → %", questionText: "7/10 = ? (%)", subtextKey: "prompt_frac_convert", answer: "70%", distractors: ["7%", "75%", "60%", "80%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_10", expression: "9/10 → %", questionText: "9/10 = ? (%)", subtextKey: "prompt_frac_convert", answer: "90%", distractors: ["9%", "80%", "95%", "75%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_11", expression: "1/2 → dec", questionText: "1/2 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.5", distractors: ["0.2", "0.25", "0.05", "0.75"], level: .beginner),
        FractionProgressItemData(key: "frac_b_12", expression: "1/4 → dec", questionText: "1/4 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.25", distractors: ["0.4", "0.5", "0.2", "0.14"], level: .beginner),
        FractionProgressItemData(key: "frac_b_13", expression: "3/4 → dec", questionText: "3/4 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.75", distractors: ["0.34", "0.7", "0.8", "0.65"], level: .beginner),
        FractionProgressItemData(key: "frac_b_14", expression: "1/5 → dec", questionText: "1/5 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.2", distractors: ["0.5", "0.15", "0.25", "0.02"], level: .beginner),
        FractionProgressItemData(key: "frac_b_15", expression: "2/5 → dec", questionText: "2/5 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.4", distractors: ["0.25", "0.5", "0.6", "0.2"], level: .beginner),
        FractionProgressItemData(key: "frac_b_16", expression: "3/5 → dec", questionText: "3/5 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.6", distractors: ["0.35", "0.5", "0.75", "0.4"], level: .beginner),
        FractionProgressItemData(key: "frac_b_17", expression: "4/5 → dec", questionText: "4/5 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.8", distractors: ["0.45", "0.75", "0.9", "0.6"], level: .beginner),
        FractionProgressItemData(key: "frac_b_18", expression: "1/10 → dec", questionText: "1/10 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.1", distractors: ["0.01", "0.2", "0.5", "1.0"], level: .beginner),
        FractionProgressItemData(key: "frac_b_19", expression: "3/10 → dec", questionText: "3/10 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.3", distractors: ["0.03", "0.35", "0.4", "0.25"], level: .beginner),
        FractionProgressItemData(key: "frac_b_20", expression: "7/10 → dec", questionText: "7/10 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.7", distractors: ["0.07", "0.75", "0.6", "0.8"], level: .beginner),
        FractionProgressItemData(key: "frac_b_21", expression: "9/10 → dec", questionText: "9/10 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.9", distractors: ["0.09", "0.8", "0.95", "0.75"], level: .beginner),
        FractionProgressItemData(key: "frac_b_22", expression: "2/2 → %", questionText: "2/2 = ? (%)", subtextKey: "prompt_frac_convert", answer: "100%", distractors: ["50%", "200%", "20%", "10%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_23", expression: "4/4 → %", questionText: "4/4 = ? (%)", subtextKey: "prompt_frac_convert", answer: "100%", distractors: ["40%", "25%", "400%", "75%"], level: .beginner),
        FractionProgressItemData(key: "frac_b_24", expression: "1/100 → %", questionText: "1/100 = ? (%)", subtextKey: "prompt_frac_convert", answer: "1%", distractors: ["10%", "0.1%", "100%", "2%"], level: .beginner),

        // Easy (30): Eighths, twentieths, twenty-fifths, fiftieths
        FractionProgressItemData(key: "frac_e_0", expression: "1/8 → %", questionText: "1/8 = ? (%)", subtextKey: "prompt_frac_convert", answer: "12.5%", distractors: ["8%", "15%", "25%", "10%"], level: .easy),
        FractionProgressItemData(key: "frac_e_1", expression: "3/8 → %", questionText: "3/8 = ? (%)", subtextKey: "prompt_frac_convert", answer: "37.5%", distractors: ["35%", "38%", "25%", "42.5%"], level: .easy),
        FractionProgressItemData(key: "frac_e_2", expression: "5/8 → %", questionText: "5/8 = ? (%)", subtextKey: "prompt_frac_convert", answer: "62.5%", distractors: ["58%", "60%", "65%", "75%"], level: .easy),
        FractionProgressItemData(key: "frac_e_3", expression: "7/8 → %", questionText: "7/8 = ? (%)", subtextKey: "prompt_frac_convert", answer: "87.5%", distractors: ["78%", "85%", "90%", "82.5%"], level: .easy),
        FractionProgressItemData(key: "frac_e_4", expression: "1/8 → dec", questionText: "1/8 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.125", distractors: ["0.18", "0.25", "0.15", "0.08"], level: .easy),
        FractionProgressItemData(key: "frac_e_5", expression: "3/8 → dec", questionText: "3/8 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.375", distractors: ["0.38", "0.35", "0.425", "0.275"], level: .easy),
        FractionProgressItemData(key: "frac_e_6", expression: "5/8 → dec", questionText: "5/8 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.625", distractors: ["0.58", "0.65", "0.6", "0.725"], level: .easy),
        FractionProgressItemData(key: "frac_e_7", expression: "7/8 → dec", questionText: "7/8 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.875", distractors: ["0.78", "0.85", "0.825", "0.9"], level: .easy),
        FractionProgressItemData(key: "frac_e_8", expression: "1/20 → %", questionText: "1/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "5%", distractors: ["2%", "10%", "20%", "4%"], level: .easy),
        FractionProgressItemData(key: "frac_e_9", expression: "3/20 → %", questionText: "3/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "15%", distractors: ["30%", "12%", "20%", "25%"], level: .easy),
        FractionProgressItemData(key: "frac_e_10", expression: "7/20 → %", questionText: "7/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "35%", distractors: ["28%", "30%", "40%", "70%"], level: .easy),
        FractionProgressItemData(key: "frac_e_11", expression: "9/20 → %", questionText: "9/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "45%", distractors: ["40%", "50%", "36%", "90%"], level: .easy),
        FractionProgressItemData(key: "frac_e_12", expression: "11/20 → %", questionText: "11/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "55%", distractors: ["45%", "60%", "50%", "65%"], level: .easy),
        FractionProgressItemData(key: "frac_e_13", expression: "13/20 → %", questionText: "13/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "65%", distractors: ["60%", "70%", "55%", "75%"], level: .easy),
        FractionProgressItemData(key: "frac_e_14", expression: "17/20 → %", questionText: "17/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "85%", distractors: ["80%", "90%", "75%", "87%"], level: .easy),
        FractionProgressItemData(key: "frac_e_15", expression: "19/20 → %", questionText: "19/20 = ? (%)", subtextKey: "prompt_frac_convert", answer: "95%", distractors: ["90%", "85%", "98%", "80%"], level: .easy),
        FractionProgressItemData(key: "frac_e_16", expression: "1/25 → %", questionText: "1/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "4%", distractors: ["5%", "2%", "25%", "8%"], level: .easy),
        FractionProgressItemData(key: "frac_e_17", expression: "2/25 → %", questionText: "2/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "8%", distractors: ["4%", "10%", "12%", "16%"], level: .easy),
        FractionProgressItemData(key: "frac_e_18", expression: "3/25 → %", questionText: "3/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "12%", distractors: ["15%", "8%", "16%", "25%"], level: .easy),
        FractionProgressItemData(key: "frac_e_19", expression: "4/25 → %", questionText: "4/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "16%", distractors: ["20%", "12%", "24%", "8%"], level: .easy),
        FractionProgressItemData(key: "frac_e_20", expression: "6/25 → %", questionText: "6/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "24%", distractors: ["25%", "20%", "30%", "18%"], level: .easy),
        FractionProgressItemData(key: "frac_e_21", expression: "7/25 → %", questionText: "7/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "28%", distractors: ["24%", "35%", "32%", "21%"], level: .easy),
        FractionProgressItemData(key: "frac_e_22", expression: "9/25 → %", questionText: "9/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "36%", distractors: ["32%", "40%", "45%", "27%"], level: .easy),
        FractionProgressItemData(key: "frac_e_23", expression: "11/25 → %", questionText: "11/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "44%", distractors: ["40%", "48%", "55%", "36%"], level: .easy),
        FractionProgressItemData(key: "frac_e_24", expression: "12/25 → %", questionText: "12/25 = ? (%)", subtextKey: "prompt_frac_convert", answer: "48%", distractors: ["50%", "44%", "52%", "40%"], level: .easy),
        FractionProgressItemData(key: "frac_e_25", expression: "1/50 → %", questionText: "1/50 = ? (%)", subtextKey: "prompt_frac_convert", answer: "2%", distractors: ["4%", "5%", "1%", "50%"], level: .easy),
        FractionProgressItemData(key: "frac_e_26", expression: "3/50 → %", questionText: "3/50 = ? (%)", subtextKey: "prompt_frac_convert", answer: "6%", distractors: ["3%", "12%", "15%", "8%"], level: .easy),
        FractionProgressItemData(key: "frac_e_27", expression: "7/50 → %", questionText: "7/50 = ? (%)", subtextKey: "prompt_frac_convert", answer: "14%", distractors: ["7%", "28%", "21%", "16%"], level: .easy),
        FractionProgressItemData(key: "frac_e_28", expression: "5/4 → %", questionText: "5/4 = ? (%)", subtextKey: "prompt_frac_convert", answer: "125%", distractors: ["80%", "120%", "150%", "75%"], level: .easy),
        FractionProgressItemData(key: "frac_e_29", expression: "3/2 → %", questionText: "3/2 = ? (%)", subtextKey: "prompt_frac_convert", answer: "150%", distractors: ["66%", "125%", "200%", "130%"], level: .easy),

        // Medium (30): Simplifying fractions
        FractionProgressItemData(key: "frac_m_0", expression: "2/4", questionText: "2/4 = ?", subtextKey: "prompt_frac_simplify", answer: "1/2", distractors: ["1/4", "2/3", "1/3", "3/4"], level: .medium),
        FractionProgressItemData(key: "frac_m_1", expression: "3/6", questionText: "3/6 = ?", subtextKey: "prompt_frac_simplify", answer: "1/2", distractors: ["1/3", "2/3", "1/6", "3/4"], level: .medium),
        FractionProgressItemData(key: "frac_m_2", expression: "4/8", questionText: "4/8 = ?", subtextKey: "prompt_frac_simplify", answer: "1/2", distractors: ["1/4", "2/3", "3/4", "1/8"], level: .medium),
        FractionProgressItemData(key: "frac_m_3", expression: "2/6", questionText: "2/6 = ?", subtextKey: "prompt_frac_simplify", answer: "1/3", distractors: ["1/2", "2/3", "1/4", "1/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_4", expression: "3/9", questionText: "3/9 = ?", subtextKey: "prompt_frac_simplify", answer: "1/3", distractors: ["1/2", "2/3", "1/9", "3/4"], level: .medium),
        FractionProgressItemData(key: "frac_m_5", expression: "4/12", questionText: "4/12 = ?", subtextKey: "prompt_frac_simplify", answer: "1/3", distractors: ["1/4", "1/2", "2/3", "1/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_6", expression: "6/9", questionText: "6/9 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["1/3", "3/4", "1/2", "3/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_7", expression: "8/12", questionText: "8/12 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/4", "1/3", "4/5", "1/2"], level: .medium),
        FractionProgressItemData(key: "frac_m_8", expression: "2/8", questionText: "2/8 = ?", subtextKey: "prompt_frac_simplify", answer: "1/4", distractors: ["1/2", "1/3", "1/8", "3/4"], level: .medium),
        FractionProgressItemData(key: "frac_m_9", expression: "3/12", questionText: "3/12 = ?", subtextKey: "prompt_frac_simplify", answer: "1/4", distractors: ["1/3", "1/6", "3/4", "1/2"], level: .medium),
        FractionProgressItemData(key: "frac_m_10", expression: "6/8", questionText: "6/8 = ?", subtextKey: "prompt_frac_simplify", answer: "3/4", distractors: ["2/3", "1/2", "4/5", "3/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_11", expression: "9/12", questionText: "9/12 = ?", subtextKey: "prompt_frac_simplify", answer: "3/4", distractors: ["2/3", "4/5", "1/4", "5/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_12", expression: "15/20", questionText: "15/20 = ?", subtextKey: "prompt_frac_simplify", answer: "3/4", distractors: ["4/5", "2/3", "3/5", "5/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_13", expression: "2/10", questionText: "2/10 = ?", subtextKey: "prompt_frac_simplify", answer: "1/5", distractors: ["1/2", "2/5", "1/4", "1/10"], level: .medium),
        FractionProgressItemData(key: "frac_m_14", expression: "4/10", questionText: "4/10 = ?", subtextKey: "prompt_frac_simplify", answer: "2/5", distractors: ["1/5", "3/5", "1/2", "4/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_15", expression: "6/10", questionText: "6/10 = ?", subtextKey: "prompt_frac_simplify", answer: "3/5", distractors: ["2/5", "2/3", "3/4", "4/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_16", expression: "8/10", questionText: "8/10 = ?", subtextKey: "prompt_frac_simplify", answer: "4/5", distractors: ["3/4", "3/5", "2/3", "5/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_17", expression: "6/15", questionText: "6/15 = ?", subtextKey: "prompt_frac_simplify", answer: "2/5", distractors: ["1/3", "3/5", "1/5", "2/3"], level: .medium),
        FractionProgressItemData(key: "frac_m_18", expression: "9/15", questionText: "9/15 = ?", subtextKey: "prompt_frac_simplify", answer: "3/5", distractors: ["2/3", "3/4", "2/5", "4/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_19", expression: "12/15", questionText: "12/15 = ?", subtextKey: "prompt_frac_simplify", answer: "4/5", distractors: ["3/4", "3/5", "2/3", "5/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_20", expression: "4/6", questionText: "4/6 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["1/3", "3/4", "1/2", "3/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_21", expression: "10/15", questionText: "10/15 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/5", "3/4", "4/5", "1/3"], level: .medium),
        FractionProgressItemData(key: "frac_m_22", expression: "12/16", questionText: "12/16 = ?", subtextKey: "prompt_frac_simplify", answer: "3/4", distractors: ["2/3", "4/5", "5/6", "3/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_23", expression: "12/18", questionText: "12/18 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/4", "3/5", "4/5", "1/2"], level: .medium),
        FractionProgressItemData(key: "frac_m_24", expression: "14/21", questionText: "14/21 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/4", "1/3", "3/5", "4/7"], level: .medium),
        FractionProgressItemData(key: "frac_m_25", expression: "15/25", questionText: "15/25 = ?", subtextKey: "prompt_frac_simplify", answer: "3/5", distractors: ["2/3", "3/4", "4/5", "2/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_26", expression: "16/24", questionText: "16/24 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/4", "4/5", "5/6", "3/8"], level: .medium),
        FractionProgressItemData(key: "frac_m_27", expression: "18/24", questionText: "18/24 = ?", subtextKey: "prompt_frac_simplify", answer: "3/4", distractors: ["2/3", "4/5", "5/6", "3/5"], level: .medium),
        FractionProgressItemData(key: "frac_m_28", expression: "20/25", questionText: "20/25 = ?", subtextKey: "prompt_frac_simplify", answer: "4/5", distractors: ["3/4", "3/5", "2/3", "5/6"], level: .medium),
        FractionProgressItemData(key: "frac_m_29", expression: "24/36", questionText: "24/36 = ?", subtextKey: "prompt_frac_simplify", answer: "2/3", distractors: ["3/4", "4/5", "5/6", "3/5"], level: .medium),

        // Hard (30): X% of a number
        FractionProgressItemData(key: "frac_h_0", expression: "10% × 50", questionText: "10% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "5", distractors: ["10", "15", "2", "50"], level: .hard),
        FractionProgressItemData(key: "frac_h_1", expression: "20% × 50", questionText: "20% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "10", distractors: ["20", "5", "15", "25"], level: .hard),
        FractionProgressItemData(key: "frac_h_2", expression: "25% × 40", questionText: "25% × 40 = ?", subtextKey: "prompt_frac_percent_of", answer: "10", distractors: ["8", "12", "15", "20"], level: .hard),
        FractionProgressItemData(key: "frac_h_3", expression: "25% × 80", questionText: "25% × 80 = ?", subtextKey: "prompt_frac_percent_of", answer: "20", distractors: ["16", "25", "40", "15"], level: .hard),
        FractionProgressItemData(key: "frac_h_4", expression: "25% × 120", questionText: "25% × 120 = ?", subtextKey: "prompt_frac_percent_of", answer: "30", distractors: ["25", "40", "24", "60"], level: .hard),
        FractionProgressItemData(key: "frac_h_5", expression: "50% × 64", questionText: "50% × 64 = ?", subtextKey: "prompt_frac_percent_of", answer: "32", distractors: ["16", "34", "28", "48"], level: .hard),
        FractionProgressItemData(key: "frac_h_6", expression: "50% × 150", questionText: "50% × 150 = ?", subtextKey: "prompt_frac_percent_of", answer: "75", distractors: ["50", "100", "65", "85"], level: .hard),
        FractionProgressItemData(key: "frac_h_7", expression: "75% × 40", questionText: "75% × 40 = ?", subtextKey: "prompt_frac_percent_of", answer: "30", distractors: ["20", "25", "35", "10"], level: .hard),
        FractionProgressItemData(key: "frac_h_8", expression: "75% × 80", questionText: "75% × 80 = ?", subtextKey: "prompt_frac_percent_of", answer: "60", distractors: ["50", "40", "70", "20"], level: .hard),
        FractionProgressItemData(key: "frac_h_9", expression: "10% × 120", questionText: "10% × 120 = ?", subtextKey: "prompt_frac_percent_of", answer: "12", distractors: ["10", "20", "24", "6"], level: .hard),
        FractionProgressItemData(key: "frac_h_10", expression: "15% × 200", questionText: "15% × 200 = ?", subtextKey: "prompt_frac_percent_of", answer: "30", distractors: ["15", "20", "40", "25"], level: .hard),
        FractionProgressItemData(key: "frac_h_11", expression: "15% × 60", questionText: "15% × 60 = ?", subtextKey: "prompt_frac_percent_of", answer: "9", distractors: ["6", "12", "15", "8"], level: .hard),
        FractionProgressItemData(key: "frac_h_12", expression: "20% × 80", questionText: "20% × 80 = ?", subtextKey: "prompt_frac_percent_of", answer: "16", distractors: ["8", "20", "24", "12"], level: .hard),
        FractionProgressItemData(key: "frac_h_13", expression: "20% × 150", questionText: "20% × 150 = ?", subtextKey: "prompt_frac_percent_of", answer: "30", distractors: ["15", "20", "45", "25"], level: .hard),
        FractionProgressItemData(key: "frac_h_14", expression: "30% × 70", questionText: "30% × 70 = ?", subtextKey: "prompt_frac_percent_of", answer: "21", distractors: ["14", "28", "30", "24"], level: .hard),
        FractionProgressItemData(key: "frac_h_15", expression: "30% × 90", questionText: "30% × 90 = ?", subtextKey: "prompt_frac_percent_of", answer: "27", distractors: ["30", "18", "36", "24"], level: .hard),
        FractionProgressItemData(key: "frac_h_16", expression: "40% × 50", questionText: "40% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "20", distractors: ["10", "25", "30", "15"], level: .hard),
        FractionProgressItemData(key: "frac_h_17", expression: "40% × 150", questionText: "40% × 150 = ?", subtextKey: "prompt_frac_percent_of", answer: "60", distractors: ["40", "45", "75", "50"], level: .hard),
        FractionProgressItemData(key: "frac_h_18", expression: "60% × 50", questionText: "60% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "30", distractors: ["20", "25", "35", "40"], level: .hard),
        FractionProgressItemData(key: "frac_h_19", expression: "70% × 80", questionText: "70% × 80 = ?", subtextKey: "prompt_frac_percent_of", answer: "56", distractors: ["48", "64", "54", "60"], level: .hard),
        FractionProgressItemData(key: "frac_h_20", expression: "80% × 50", questionText: "80% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "40", distractors: ["30", "35", "45", "20"], level: .hard),
        FractionProgressItemData(key: "frac_h_21", expression: "90% × 60", questionText: "90% × 60 = ?", subtextKey: "prompt_frac_percent_of", answer: "54", distractors: ["45", "48", "56", "50"], level: .hard),
        FractionProgressItemData(key: "frac_h_22", expression: "5% × 200", questionText: "5% × 200 = ?", subtextKey: "prompt_frac_percent_of", answer: "10", distractors: ["5", "20", "40", "15"], level: .hard),
        FractionProgressItemData(key: "frac_h_23", expression: "5% × 80", questionText: "5% × 80 = ?", subtextKey: "prompt_frac_percent_of", answer: "4", distractors: ["8", "5", "16", "2"], level: .hard),
        FractionProgressItemData(key: "frac_h_24", expression: "12% × 50", questionText: "12% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "6", distractors: ["12", "4", "8", "10"], level: .hard),
        FractionProgressItemData(key: "frac_h_25", expression: "120% × 50", questionText: "120% × 50 = ?", subtextKey: "prompt_frac_percent_of", answer: "60", distractors: ["50", "70", "10", "55"], level: .hard),
        FractionProgressItemData(key: "frac_h_26", expression: "150% × 40", questionText: "150% × 40 = ?", subtextKey: "prompt_frac_percent_of", answer: "60", distractors: ["50", "80", "45", "20"], level: .hard),
        FractionProgressItemData(key: "frac_h_27", expression: "200% × 35", questionText: "200% × 35 = ?", subtextKey: "prompt_frac_percent_of", answer: "70", distractors: ["35", "105", "140", "700"], level: .hard),
        FractionProgressItemData(key: "frac_h_28", expression: "1% × 500", questionText: "1% × 500 = ?", subtextKey: "prompt_frac_percent_of", answer: "5", distractors: ["50", "1", "10", "0.5"], level: .hard),
        FractionProgressItemData(key: "frac_h_29", expression: "2% × 150", questionText: "2% × 150 = ?", subtextKey: "prompt_frac_percent_of", answer: "3", distractors: ["30", "2", "6", "1.5"], level: .hard),

        // Ultimate (30): Repeating decimals & fraction arithmetic
        FractionProgressItemData(key: "frac_u_0", expression: "1/3 → dec", questionText: "1/3 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(3)", distractors: ["0.3", "0.(6)", "0.(1)", "0.25"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_1", expression: "2/3 → dec", questionText: "2/3 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(6)", distractors: ["0.6", "0.(3)", "0.75", "0.(2)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_2", expression: "1/6 → dec", questionText: "1/6 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.1(6)", distractors: ["0.(6)", "0.(16)", "0.15", "0.2(6)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_3", expression: "5/6 → dec", questionText: "5/6 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.8(3)", distractors: ["0.85", "0.(83)", "0.7(6)", "0.8(6)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_4", expression: "1/9 → dec", questionText: "1/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(1)", distractors: ["0.1", "0.(9)", "0.(09)", "0.(2)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_5", expression: "2/9 → dec", questionText: "2/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(2)", distractors: ["0.2", "0.(1)", "0.(3)", "0.(18)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_6", expression: "4/9 → dec", questionText: "4/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(4)", distractors: ["0.4", "0.(5)", "0.(3)", "0.45"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_7", expression: "5/9 → dec", questionText: "5/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(5)", distractors: ["0.5", "0.(4)", "0.(6)", "0.55"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_8", expression: "7/9 → dec", questionText: "7/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(7)", distractors: ["0.7", "0.(8)", "0.(6)", "0.75"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_9", expression: "8/9 → dec", questionText: "8/9 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(8)", distractors: ["0.8", "0.(7)", "0.(9)", "0.85"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_10", expression: "1/11 → dec", questionText: "1/11 = ? (0.x)", subtextKey: "prompt_frac_convert", answer: "0.(09)", distractors: ["0.(1)", "0.(11)", "0.0(9)", "0.(90)"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_11", expression: "1/2 + 1/4", questionText: "1/2 + 1/4 = ?", subtextKey: "prompt_frac_calc", answer: "3/4", distractors: ["2/6", "1/3", "2/4", "5/8"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_12", expression: "1/2 - 1/4", questionText: "1/2 - 1/4 = ?", subtextKey: "prompt_frac_calc", answer: "1/4", distractors: ["1/2", "1/8", "3/4", "1/3"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_13", expression: "1/3 + 1/6", questionText: "1/3 + 1/6 = ?", subtextKey: "prompt_frac_calc", answer: "1/2", distractors: ["2/9", "2/3", "1/3", "5/6"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_14", expression: "2/3 - 1/6", questionText: "2/3 - 1/6 = ?", subtextKey: "prompt_frac_calc", answer: "1/2", distractors: ["1/3", "1/6", "2/3", "5/6"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_15", expression: "1/2 + 1/3", questionText: "1/2 + 1/3 = ?", subtextKey: "prompt_frac_calc", answer: "5/6", distractors: ["2/5", "2/3", "3/5", "3/4"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_16", expression: "1/2 - 1/3", questionText: "1/2 - 1/3 = ?", subtextKey: "prompt_frac_calc", answer: "1/6", distractors: ["1/5", "1/3", "1/2", "1/4"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_17", expression: "1/4 + 1/8", questionText: "1/4 + 1/8 = ?", subtextKey: "prompt_frac_calc", answer: "3/8", distractors: ["2/12", "1/6", "5/8", "1/2"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_18", expression: "3/4 - 1/8", questionText: "3/4 - 1/8 = ?", subtextKey: "prompt_frac_calc", answer: "5/8", distractors: ["2/4", "1/2", "3/8", "7/8"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_19", expression: "1/5 + 1/10", questionText: "1/5 + 1/10 = ?", subtextKey: "prompt_frac_calc", answer: "3/10", distractors: ["2/15", "2/5", "1/5", "7/10"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_20", expression: "2/5 + 3/10", questionText: "2/5 + 3/10 = ?", subtextKey: "prompt_frac_calc", answer: "7/10", distractors: ["5/15", "1/2", "3/5", "9/10"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_21", expression: "1/3 + 1/9", questionText: "1/3 + 1/9 = ?", subtextKey: "prompt_frac_calc", answer: "4/9", distractors: ["2/12", "2/9", "1/2", "5/9"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_22", expression: "2/3 + 1/6", questionText: "2/3 + 1/6 = ?", subtextKey: "prompt_frac_calc", answer: "5/6", distractors: ["3/9", "3/4", "1/2", "2/3"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_23", expression: "3/4 + 1/8", questionText: "3/4 + 1/8 = ?", subtextKey: "prompt_frac_calc", answer: "7/8", distractors: ["4/12", "5/8", "3/4", "1"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_24", expression: "1/2 × 1/2", questionText: "1/2 × 1/2 = ?", subtextKey: "prompt_frac_calc", answer: "1/4", distractors: ["1", "1/2", "2/4", "1/8"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_25", expression: "1/2 × 2/3", questionText: "1/2 × 2/3 = ?", subtextKey: "prompt_frac_calc", answer: "1/3", distractors: ["1/2", "2/5", "2/3", "3/4"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_26", expression: "3/4 × 2/3", questionText: "3/4 × 2/3 = ?", subtextKey: "prompt_frac_calc", answer: "1/2", distractors: ["5/7", "2/3", "3/4", "1/4"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_27", expression: "1/2 ÷ 1/4", questionText: "1/2 ÷ 1/4 = ?", subtextKey: "prompt_frac_calc", answer: "2", distractors: ["1/8", "1/2", "4", "1/4"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_28", expression: "3/4 ÷ 1/4", questionText: "3/4 ÷ 1/4 = ?", subtextKey: "prompt_frac_calc", answer: "3", distractors: ["3/16", "1/3", "4", "2"], level: .ultimate),
        FractionProgressItemData(key: "frac_u_29", expression: "2/3 ÷ 1/3", questionText: "2/3 ÷ 1/3 = ?", subtextKey: "prompt_frac_calc", answer: "2", distractors: ["2/9", "1/2", "3", "1"], level: .ultimate)
    ]

    func fractionPool(for level: GameLevel) -> [FractionProgressItemData] {
        return allFractionItems.filter { $0.level == level }
    }

    private func makeFractionQuestion(from item: FractionProgressItemData, maxTime: Double) -> Question {
        let options = makeStringOptions(correct: item.answer, distractors: item.distractors)
        let correctIdx = options.firstIndex(of: item.answer) ?? 0
        return Question(
            itemKey: item.key,
            text: item.questionText,
            subtext: NSLocalizedString(item.subtextKey, comment: ""),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime
        )
    }

    private func generateFractions(level: GameLevel, maxTime: Double) -> Question {
        if level == .godlike {
            let templates: [(Int, String, Int, Int, String, Int)] = [
                (25, "1/2", 2, 1, "+", Int.random(in: 1...6) * 20),
                (75, "1/4", 4, 1, "-", Int.random(in: 1...5) * 40),
                (20, "3/4", 4, 3, "+", Int.random(in: 2...6) * 20),
                (50, "2/5", 5, 2, "+", Int.random(in: 2...8) * 10),
                (40, "3/5", 5, 3, "-", Int.random(in: 2...6) * 25)
            ]
            let picked = templates.randomElement()!
            let pct = picked.0
            let fracStr = picked.1
            let denom = picked.2
            let numer = picked.3
            let op = picked.4
            let baseA = picked.5
            let baseB = Int.random(in: 2...8) * denom
            let leftVal = (pct * baseA) / 100
            let rightVal = (baseB / denom) * numer
            let result: Int
            let expr: String
            if op == "-" && leftVal >= rightVal {
                result = leftVal - rightVal
                expr = "\(pct)% × \(baseA) - \(fracStr) × \(baseB)"
            } else {
                result = leftVal + rightVal
                expr = "\(pct)% × \(baseA) + \(fracStr) × \(baseB)"
            }
            let context = [leftVal, rightVal, result + 10, max(0, result - 10), leftVal + baseB / denom]
            let options = makeNumericOptions(correct: result, range: 20, minVal: 0, contextCandidates: context)
            let correctIdx = options.firstIndex(of: "\(result)") ?? 0
            return Question(
                itemKey: "math_19_\(expr)",
                text: expr,
                subtext: NSLocalizedString("prompt_frac_calc", comment: "Calculate:"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            let pool = fractionPool(for: level)
            guard let item = pool.randomElement() else {
                return Question(text: "1/2 = ? (%)", options: ["25%", "50%", "75%", "20%"], correctIndex: 1, maxTime: maxTime)
            }
            return makeFractionQuestion(from: item, maxTime: maxTime)
        }
    }

    // MARK: - 20. Unit Conversions & SI Prefixes
    let allUnitConversionItems: [UnitConversionItem] = [
        // Beginner (25): Length & Mass
        UnitConversionItem(key: "unit_0", expression: "1 km", questionText: "1 km = ? m", answer: "1000 m", distractors: ["100 m", "10 000 m", "10 m", "500 m"], level: .beginner),
        UnitConversionItem(key: "unit_1", expression: "1 m", questionText: "1 m = ? cm", answer: "100 cm", distractors: ["10 cm", "1000 cm", "50 cm", "200 cm"], level: .beginner),
        UnitConversionItem(key: "unit_2", expression: "1 cm", questionText: "1 cm = ? mm", answer: "10 mm", distractors: ["100 mm", "1000 mm", "5 mm", "20 mm"], level: .beginner),
        UnitConversionItem(key: "unit_3", expression: "1 dm", questionText: "1 dm = ? cm", answer: "10 cm", distractors: ["100 cm", "1000 cm", "1 cm", "50 cm"], level: .beginner),
        UnitConversionItem(key: "unit_4", expression: "1 m", questionText: "1 m = ? dm", answer: "10 dm", distractors: ["100 dm", "1000 dm", "5 dm", "20 dm"], level: .beginner),
        UnitConversionItem(key: "unit_5", expression: "1 kg", questionText: "1 kg = ? g", answer: "1000 g", distractors: ["100 g", "10 000 g", "500 g", "10 g"], level: .beginner),
        UnitConversionItem(key: "unit_6", expression: "1 t", questionText: "1 t = ? kg", answer: "1000 kg", distractors: ["100 kg", "10 000 kg", "500 kg", "2000 kg"], level: .beginner),
        UnitConversionItem(key: "unit_7", expression: "1 g", questionText: "1 g = ? mg", answer: "1000 mg", distractors: ["100 mg", "10 mg", "10 000 mg", "500 mg"], level: .beginner),
        UnitConversionItem(key: "unit_8", expression: "1 dag", questionText: "1 dag = ? g", answer: "10 g", distractors: ["100 g", "1000 g", "5 g", "20 g"], level: .beginner),
        UnitConversionItem(key: "unit_9", expression: "1 kg", questionText: "1 kg = ? dag", answer: "100 dag", distractors: ["10 dag", "1000 dag", "50 dag", "200 dag"], level: .beginner),
        UnitConversionItem(key: "unit_10", expression: "2 km", questionText: "2 km = ? m", answer: "2000 m", distractors: ["200 m", "20 000 m", "20 m", "1000 m"], level: .beginner),
        UnitConversionItem(key: "unit_11", expression: "5 m", questionText: "5 m = ? cm", answer: "500 cm", distractors: ["50 cm", "5000 cm", "50000 cm", "250 cm"], level: .beginner),
        UnitConversionItem(key: "unit_12", expression: "3 cm", questionText: "3 cm = ? mm", answer: "30 mm", distractors: ["300 mm", "3000 mm", "3 mm", "15 mm"], level: .beginner),
        UnitConversionItem(key: "unit_13", expression: "4 kg", questionText: "4 kg = ? g", answer: "4000 g", distractors: ["400 g", "40 000 g", "40 g", "2000 g"], level: .beginner),
        UnitConversionItem(key: "unit_14", expression: "3 t", questionText: "3 t = ? kg", answer: "3000 kg", distractors: ["300 kg", "30 000 kg", "30 kg", "1500 kg"], level: .beginner),
        UnitConversionItem(key: "unit_15", expression: "10 m", questionText: "10 m = ? cm", answer: "1000 cm", distractors: ["100 cm", "10 000 cm", "500 cm", "200 cm"], level: .beginner),
        UnitConversionItem(key: "unit_16", expression: "7 km", questionText: "7 km = ? m", answer: "7000 m", distractors: ["700 m", "70 000 m", "70 m", "3500 m"], level: .beginner),
        UnitConversionItem(key: "unit_17", expression: "6 kg", questionText: "6 kg = ? g", answer: "6000 g", distractors: ["600 g", "60 000 g", "60 g", "3000 g"], level: .beginner),
        UnitConversionItem(key: "unit_18", expression: "8 dm", questionText: "8 dm = ? cm", answer: "80 cm", distractors: ["800 cm", "8 cm", "8000 cm", "40 cm"], level: .beginner),
        UnitConversionItem(key: "unit_19", expression: "5 dag", questionText: "5 dag = ? g", answer: "50 g", distractors: ["500 g", "5 g", "5000 g", "25 g"], level: .beginner),
        UnitConversionItem(key: "unit_20", expression: "200 cm", questionText: "200 cm = ? m", answer: "2 m", distractors: ["20 m", "0.2 m", "2000 m", "4 m"], level: .beginner),
        UnitConversionItem(key: "unit_21", expression: "3000 m", questionText: "3000 m = ? km", answer: "3 km", distractors: ["30 km", "300 km", "0.3 km", "6 km"], level: .beginner),
        UnitConversionItem(key: "unit_22", expression: "5000 g", questionText: "5000 g = ? kg", answer: "5 kg", distractors: ["50 kg", "500 kg", "0.5 kg", "10 kg"], level: .beginner),
        UnitConversionItem(key: "unit_23", expression: "40 mm", questionText: "40 mm = ? cm", answer: "4 cm", distractors: ["400 cm", "0.4 cm", "40 cm", "8 cm"], level: .beginner),
        UnitConversionItem(key: "unit_24", expression: "2000 kg", questionText: "2000 kg = ? t", answer: "2 t", distractors: ["20 t", "200 t", "0.2 t", "4 t"], level: .beginner),

        // Easy (25): Time & Volume
        UnitConversionItem(key: "unit_25", expression: "1 min", questionText: "1 min = ? s", answer: "60 s", distractors: ["100 s", "30 s", "120 s", "600 s"], level: .easy),
        UnitConversionItem(key: "unit_26", expression: "1 h", questionText: "1 h = ? min", answer: "60 min", distractors: ["100 min", "24 min", "30 min", "120 min"], level: .easy),
        UnitConversionItem(key: "unit_27", expression: "1 d", questionText: "1 d = ? h", answer: "24 h", distractors: ["12 h", "48 h", "60 h", "36 h"], level: .easy),
        UnitConversionItem(key: "unit_28", expression: "1 L", questionText: "1 L = ? mL", answer: "1000 mL", distractors: ["100 mL", "10 000 mL", "500 mL", "10 mL"], level: .easy),
        UnitConversionItem(key: "unit_29", expression: "1 h", questionText: "1 h = ? s", answer: "3600 s", distractors: ["600 s", "360 s", "1200 s", "60 s"], level: .easy),
        UnitConversionItem(key: "unit_30", expression: "2 min", questionText: "2 min = ? s", answer: "120 s", distractors: ["200 s", "60 s", "180 s", "90 s"], level: .easy),
        UnitConversionItem(key: "unit_31", expression: "3 min", questionText: "3 min = ? s", answer: "180 s", distractors: ["300 s", "120 s", "240 s", "150 s"], level: .easy),
        UnitConversionItem(key: "unit_32", expression: "5 min", questionText: "5 min = ? s", answer: "300 s", distractors: ["500 s", "250 s", "360 s", "180 s"], level: .easy),
        UnitConversionItem(key: "unit_33", expression: "2 h", questionText: "2 h = ? min", answer: "120 min", distractors: ["200 min", "60 min", "180 min", "90 min"], level: .easy),
        UnitConversionItem(key: "unit_34", expression: "3 h", questionText: "3 h = ? min", answer: "180 min", distractors: ["300 min", "120 min", "240 min", "150 min"], level: .easy),
        UnitConversionItem(key: "unit_35", expression: "2 d", questionText: "2 d = ? h", answer: "48 h", distractors: ["24 h", "36 h", "72 h", "96 h"], level: .easy),
        UnitConversionItem(key: "unit_36", expression: "3 d", questionText: "3 d = ? h", answer: "72 h", distractors: ["48 h", "60 h", "96 h", "36 h"], level: .easy),
        UnitConversionItem(key: "unit_37", expression: "7 d", questionText: "7 d = ? h", answer: "168 h", distractors: ["144 h", "120 h", "192 h", "70 h"], level: .easy),
        UnitConversionItem(key: "unit_38", expression: "2 L", questionText: "2 L = ? mL", answer: "2000 mL", distractors: ["200 mL", "20 000 mL", "1000 mL", "500 mL"], level: .easy),
        UnitConversionItem(key: "unit_39", expression: "5 L", questionText: "5 L = ? mL", answer: "5000 mL", distractors: ["500 mL", "50 000 mL", "2500 mL", "50 mL"], level: .easy),
        UnitConversionItem(key: "unit_40", expression: "1 dL", questionText: "1 dL = ? mL", answer: "100 mL", distractors: ["10 mL", "1000 mL", "50 mL", "200 mL"], level: .easy),
        UnitConversionItem(key: "unit_41", expression: "1 L", questionText: "1 L = ? dL", answer: "10 dL", distractors: ["100 dL", "1000 dL", "5 dL", "20 dL"], level: .easy),
        UnitConversionItem(key: "unit_42", expression: "1 cL", questionText: "1 cL = ? mL", answer: "10 mL", distractors: ["100 mL", "1000 mL", "1 mL", "50 mL"], level: .easy),
        UnitConversionItem(key: "unit_43", expression: "1 L", questionText: "1 L = ? cL", answer: "100 cL", distractors: ["10 cL", "1000 cL", "50 cL", "200 cL"], level: .easy),
        UnitConversionItem(key: "unit_44", expression: "120 s", questionText: "120 s = ? min", answer: "2 min", distractors: ["1.2 min", "3 min", "20 min", "4 min"], level: .easy),
        UnitConversionItem(key: "unit_45", expression: "180 min", questionText: "180 min = ? h", answer: "3 h", distractors: ["1.8 h", "2 h", "4 h", "6 h"], level: .easy),
        UnitConversionItem(key: "unit_46", expression: "48 h", questionText: "48 h = ? d", answer: "2 d", distractors: ["4 d", "3 d", "1 d", "6 d"], level: .easy),
        UnitConversionItem(key: "unit_47", expression: "3000 mL", questionText: "3000 mL = ? L", answer: "3 L", distractors: ["30 L", "300 L", "0.3 L", "6 L"], level: .easy),
        UnitConversionItem(key: "unit_48", expression: "500 mL", questionText: "500 mL = ? dL", answer: "5 dL", distractors: ["50 dL", "0.5 dL", "500 dL", "2.5 dL"], level: .easy),
        UnitConversionItem(key: "unit_49", expression: "10 min", questionText: "10 min = ? s", answer: "600 s", distractors: ["100 s", "1000 s", "360 s", "300 s"], level: .easy),

        // Medium (25): Decimal & Fractional Conversions
        UnitConversionItem(key: "unit_50", expression: "0.5 km", questionText: "0.5 km = ? m", answer: "500 m", distractors: ["50 m", "5000 m", "5 m", "250 m"], level: .medium),
        UnitConversionItem(key: "unit_51", expression: "0.25 km", questionText: "0.25 km = ? m", answer: "250 m", distractors: ["25 m", "2500 m", "500 m", "125 m"], level: .medium),
        UnitConversionItem(key: "unit_52", expression: "1.5 km", questionText: "1.5 km = ? m", answer: "1500 m", distractors: ["150 m", "15 000 m", "1050 m", "500 m"], level: .medium),
        UnitConversionItem(key: "unit_53", expression: "0.5 m", questionText: "0.5 m = ? cm", answer: "50 cm", distractors: ["5 cm", "500 cm", "25 cm", "150 cm"], level: .medium),
        UnitConversionItem(key: "unit_54", expression: "1.5 m", questionText: "1.5 m = ? cm", answer: "150 cm", distractors: ["15 cm", "1500 cm", "105 cm", "50 cm"], level: .medium),
        UnitConversionItem(key: "unit_55", expression: "2.5 cm", questionText: "2.5 cm = ? mm", answer: "25 mm", distractors: ["250 mm", "2.5 mm", "2500 mm", "50 mm"], level: .medium),
        UnitConversionItem(key: "unit_56", expression: "0.5 kg", questionText: "0.5 kg = ? g", answer: "500 g", distractors: ["50 g", "5000 g", "5 g", "250 g"], level: .medium),
        UnitConversionItem(key: "unit_57", expression: "0.25 kg", questionText: "0.25 kg = ? g", answer: "250 g", distractors: ["25 g", "2500 g", "500 g", "125 g"], level: .medium),
        UnitConversionItem(key: "unit_58", expression: "1.5 kg", questionText: "1.5 kg = ? g", answer: "1500 g", distractors: ["150 g", "15 000 g", "1050 g", "500 g"], level: .medium),
        UnitConversionItem(key: "unit_59", expression: "0.5 t", questionText: "0.5 t = ? kg", answer: "500 kg", distractors: ["50 kg", "5000 kg", "5 kg", "250 kg"], level: .medium),
        UnitConversionItem(key: "unit_60", expression: "2.5 t", questionText: "2.5 t = ? kg", answer: "2500 kg", distractors: ["250 kg", "25 000 kg", "2050 kg", "500 kg"], level: .medium),
        UnitConversionItem(key: "unit_61", expression: "0.5 L", questionText: "0.5 L = ? mL", answer: "500 mL", distractors: ["50 mL", "5000 mL", "5 mL", "250 mL"], level: .medium),
        UnitConversionItem(key: "unit_62", expression: "0.25 L", questionText: "0.25 L = ? mL", answer: "250 mL", distractors: ["25 mL", "2500 mL", "500 mL", "125 mL"], level: .medium),
        UnitConversionItem(key: "unit_63", expression: "1.5 L", questionText: "1.5 L = ? mL", answer: "1500 mL", distractors: ["150 mL", "15 000 mL", "1050 mL", "500 mL"], level: .medium),
        UnitConversionItem(key: "unit_64", expression: "0.5 h", questionText: "0.5 h = ? min", answer: "30 min", distractors: ["50 min", "15 min", "45 min", "25 min"], level: .medium),
        UnitConversionItem(key: "unit_65", expression: "0.25 h", questionText: "0.25 h = ? min", answer: "15 min", distractors: ["25 min", "30 min", "20 min", "12 min"], level: .medium),
        UnitConversionItem(key: "unit_66", expression: "0.75 h", questionText: "0.75 h = ? min", answer: "45 min", distractors: ["75 min", "35 min", "40 min", "50 min"], level: .medium),
        UnitConversionItem(key: "unit_67", expression: "1.5 h", questionText: "1.5 h = ? min", answer: "90 min", distractors: ["150 min", "75 min", "105 min", "80 min"], level: .medium),
        UnitConversionItem(key: "unit_68", expression: "0.5 min", questionText: "0.5 min = ? s", answer: "30 s", distractors: ["50 s", "15 s", "45 s", "20 s"], level: .medium),
        UnitConversionItem(key: "unit_69", expression: "1.5 min", questionText: "1.5 min = ? s", answer: "90 s", distractors: ["150 s", "75 s", "120 s", "105 s"], level: .medium),
        UnitConversionItem(key: "unit_70", expression: "500 m", questionText: "500 m = ? km", answer: "0.5 km", distractors: ["5 km", "0.05 km", "50 km", "0.25 km"], level: .medium),
        UnitConversionItem(key: "unit_71", expression: "250 g", questionText: "250 g = ? kg", answer: "0.25 kg", distractors: ["2.5 kg", "0.025 kg", "0.5 kg", "25 kg"], level: .medium),
        UnitConversionItem(key: "unit_72", expression: "150 cm", questionText: "150 cm = ? m", answer: "1.5 m", distractors: ["15 m", "0.15 m", "1.05 m", "2.5 m"], level: .medium),
        UnitConversionItem(key: "unit_73", expression: "750 mL", questionText: "750 mL = ? L", answer: "0.75 L", distractors: ["7.5 L", "0.075 L", "0.5 L", "75 L"], level: .medium),
        UnitConversionItem(key: "unit_74", expression: "45 min", questionText: "45 min = ? h", answer: "0.75 h", distractors: ["0.45 h", "0.5 h", "0.8 h", "1.25 h"], level: .medium),

        // Hard (25): Area & Volume
        UnitConversionItem(key: "unit_75", expression: "1 m²", questionText: "1 m² = ? dm²", answer: "100 dm²", distractors: ["10 dm²", "1000 dm²", "10 000 dm²", "50 dm²"], level: .hard),
        UnitConversionItem(key: "unit_76", expression: "1 dm²", questionText: "1 dm² = ? cm²", answer: "100 cm²", distractors: ["10 cm²", "1000 cm²", "10 000 cm²", "50 cm²"], level: .hard),
        UnitConversionItem(key: "unit_77", expression: "1 cm²", questionText: "1 cm² = ? mm²", answer: "100 mm²", distractors: ["10 mm²", "1000 mm²", "10 000 mm²", "50 mm²"], level: .hard),
        UnitConversionItem(key: "unit_78", expression: "1 m²", questionText: "1 m² = ? cm²", answer: "10 000 cm²", distractors: ["100 cm²", "1000 cm²", "1 000 000 cm²", "200 cm²"], level: .hard),
        UnitConversionItem(key: "unit_79", expression: "1 a", questionText: "1 a = ? m²", answer: "100 m²", distractors: ["10 m²", "1000 m²", "10 000 m²", "50 m²"], level: .hard),
        UnitConversionItem(key: "unit_80", expression: "1 ha", questionText: "1 ha = ? m²", answer: "10 000 m²", distractors: ["100 m²", "1000 m²", "100 000 m²", "1 000 000 m²"], level: .hard),
        UnitConversionItem(key: "unit_81", expression: "1 ha", questionText: "1 ha = ? a", answer: "100 a", distractors: ["10 a", "1000 a", "10 000 a", "50 a"], level: .hard),
        UnitConversionItem(key: "unit_82", expression: "1 km²", questionText: "1 km² = ? ha", answer: "100 ha", distractors: ["10 ha", "1000 ha", "10 000 ha", "50 ha"], level: .hard),
        UnitConversionItem(key: "unit_83", expression: "1 km²", questionText: "1 km² = ? m²", answer: "1 000 000 m²", distractors: ["1000 m²", "10 000 m²", "100 000 m²", "10 000 000 m²"], level: .hard),
        UnitConversionItem(key: "unit_84", expression: "1 dm³", questionText: "1 dm³ = ? L", answer: "1 L", distractors: ["10 L", "100 L", "1000 L", "0.1 L"], level: .hard),
        UnitConversionItem(key: "unit_85", expression: "1 cm³", questionText: "1 cm³ = ? mL", answer: "1 mL", distractors: ["10 mL", "100 mL", "1000 mL", "0.1 mL"], level: .hard),
        UnitConversionItem(key: "unit_86", expression: "1 m³", questionText: "1 m³ = ? L", answer: "1000 L", distractors: ["100 L", "10 L", "10 000 L", "500 L"], level: .hard),
        UnitConversionItem(key: "unit_87", expression: "1 m³", questionText: "1 m³ = ? dm³", answer: "1000 dm³", distractors: ["100 dm³", "10 dm³", "10 000 dm³", "1 000 000 dm³"], level: .hard),
        UnitConversionItem(key: "unit_88", expression: "1 dm³", questionText: "1 dm³ = ? cm³", answer: "1000 cm³", distractors: ["100 cm³", "10 cm³", "10 000 cm³", "1 000 000 cm³"], level: .hard),
        UnitConversionItem(key: "unit_89", expression: "1 cm³", questionText: "1 cm³ = ? mm³", answer: "1000 mm³", distractors: ["100 mm³", "10 mm³", "10 000 mm³", "500 mm³"], level: .hard),
        UnitConversionItem(key: "unit_90", expression: "2 m²", questionText: "2 m² = ? dm²", answer: "200 dm²", distractors: ["20 dm²", "2000 dm²", "20 000 dm²", "400 dm²"], level: .hard),
        UnitConversionItem(key: "unit_91", expression: "5 ha", questionText: "5 ha = ? a", answer: "500 a", distractors: ["50 a", "5000 a", "50 000 a", "250 a"], level: .hard),
        UnitConversionItem(key: "unit_92", expression: "3 ha", questionText: "3 ha = ? m²", answer: "30 000 m²", distractors: ["300 m²", "3000 m²", "300 000 m²", "3 000 000 m²"], level: .hard),
        UnitConversionItem(key: "unit_93", expression: "2 m³", questionText: "2 m³ = ? L", answer: "2000 L", distractors: ["200 L", "20 000 L", "20 L", "1000 L"], level: .hard),
        UnitConversionItem(key: "unit_94", expression: "5 dm³", questionText: "5 dm³ = ? cm³", answer: "5000 cm³", distractors: ["500 cm³", "50 cm³", "50 000 cm³", "2500 cm³"], level: .hard),
        UnitConversionItem(key: "unit_95", expression: "0.5 ha", questionText: "0.5 ha = ? m²", answer: "5000 m²", distractors: ["500 m²", "50 m²", "50 000 m²", "2500 m²"], level: .hard),
        UnitConversionItem(key: "unit_96", expression: "0.5 m³", questionText: "0.5 m³ = ? L", answer: "500 L", distractors: ["50 L", "5000 L", "5 L", "250 L"], level: .hard),
        UnitConversionItem(key: "unit_97", expression: "250 cm³", questionText: "250 cm³ = ? mL", answer: "250 mL", distractors: ["25 mL", "2500 mL", "2.5 mL", "500 mL"], level: .hard),
        UnitConversionItem(key: "unit_98", expression: "1000 cm³", questionText: "1000 cm³ = ? L", answer: "1 L", distractors: ["10 L", "100 L", "0.1 L", "1000 L"], level: .hard),
        UnitConversionItem(key: "unit_99", expression: "200 a", questionText: "200 a = ? ha", answer: "2 ha", distractors: ["20 ha", "0.2 ha", "200 ha", "2000 ha"], level: .hard),

        // Ultimate (25): Speed & SI Prefixes
        UnitConversionItem(key: "unit_100", expression: "3.6 km/h", questionText: "3.6 km/h = ? m/s", answer: "1 m/s", distractors: ["3.6 m/s", "10 m/s", "0.1 m/s", "2 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_101", expression: "18 km/h", questionText: "18 km/h = ? m/s", answer: "5 m/s", distractors: ["10 m/s", "18 m/s", "3 m/s", "6 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_102", expression: "36 km/h", questionText: "36 km/h = ? m/s", answer: "10 m/s", distractors: ["3.6 m/s", "12 m/s", "20 m/s", "15 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_103", expression: "54 km/h", questionText: "54 km/h = ? m/s", answer: "15 m/s", distractors: ["12 m/s", "18 m/s", "20 m/s", "10 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_104", expression: "72 km/h", questionText: "72 km/h = ? m/s", answer: "20 m/s", distractors: ["15 m/s", "25 m/s", "36 m/s", "18 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_105", expression: "90 km/h", questionText: "90 km/h = ? m/s", answer: "25 m/s", distractors: ["20 m/s", "30 m/s", "35 m/s", "15 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_106", expression: "108 km/h", questionText: "108 km/h = ? m/s", answer: "30 m/s", distractors: ["25 m/s", "35 m/s", "40 m/s", "27 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_107", expression: "126 km/h", questionText: "126 km/h = ? m/s", answer: "35 m/s", distractors: ["30 m/s", "40 m/s", "25 m/s", "45 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_108", expression: "144 km/h", questionText: "144 km/h = ? m/s", answer: "40 m/s", distractors: ["35 m/s", "45 m/s", "50 m/s", "36 m/s"], level: .ultimate),
        UnitConversionItem(key: "unit_109", expression: "10 m/s", questionText: "10 m/s = ? km/h", answer: "36 km/h", distractors: ["18 km/h", "72 km/h", "60 km/h", "100 km/h"], level: .ultimate),
        UnitConversionItem(key: "unit_110", expression: "20 m/s", questionText: "20 m/s = ? km/h", answer: "72 km/h", distractors: ["36 km/h", "54 km/h", "90 km/h", "120 km/h"], level: .ultimate),
        UnitConversionItem(key: "unit_111", expression: "25 m/s", questionText: "25 m/s = ? km/h", answer: "90 km/h", distractors: ["72 km/h", "108 km/h", "75 km/h", "100 km/h"], level: .ultimate),
        UnitConversionItem(key: "unit_112", expression: "30 m/s", questionText: "30 m/s = ? km/h", answer: "108 km/h", distractors: ["90 km/h", "120 km/h", "72 km/h", "144 km/h"], level: .ultimate),
        UnitConversionItem(key: "unit_113", expression: "5 m/s", questionText: "5 m/s = ? km/h", answer: "18 km/h", distractors: ["36 km/h", "9 km/h", "15 km/h", "30 km/h"], level: .ultimate),
        UnitConversionItem(key: "unit_114", expression: "kilo (k)", questionText: "kilo (k) = ?", answer: "10³", distractors: ["10²", "10⁶", "10⁻³", "10⁹"], level: .ultimate),
        UnitConversionItem(key: "unit_115", expression: "mega (M)", questionText: "mega (M) = ?", answer: "10⁶", distractors: ["10³", "10⁹", "10⁻⁶", "10¹²"], level: .ultimate),
        UnitConversionItem(key: "unit_116", expression: "giga (G)", questionText: "giga (G) = ?", answer: "10⁹", distractors: ["10⁶", "10¹²", "10⁻⁹", "10³"], level: .ultimate),
        UnitConversionItem(key: "unit_117", expression: "tera (T)", questionText: "tera (T) = ?", answer: "10¹²", distractors: ["10⁹", "10¹⁵", "10⁶", "10⁻¹²"], level: .ultimate),
        UnitConversionItem(key: "unit_118", expression: "deci (d)", questionText: "deci (d) = ?", answer: "10⁻¹", distractors: ["10⁻²", "10¹", "10⁻³", "10²"], level: .ultimate),
        UnitConversionItem(key: "unit_119", expression: "centi (c)", questionText: "centi (c) = ?", answer: "10⁻²", distractors: ["10⁻¹", "10⁻³", "10²", "10⁻⁶"], level: .ultimate),
        UnitConversionItem(key: "unit_120", expression: "milli (m)", questionText: "milli (m) = ?", answer: "10⁻³", distractors: ["10⁻²", "10⁻⁶", "10³", "10⁻⁹"], level: .ultimate),
        UnitConversionItem(key: "unit_121", expression: "micro (μ)", questionText: "micro (μ) = ?", answer: "10⁻⁶", distractors: ["10⁻³", "10⁻⁹", "10⁶", "10⁻¹²"], level: .ultimate),
        UnitConversionItem(key: "unit_122", expression: "nano (n)", questionText: "nano (n) = ?", answer: "10⁻⁹", distractors: ["10⁻⁶", "10⁻¹²", "10⁹", "10⁻³"], level: .ultimate),
        UnitConversionItem(key: "unit_123", expression: "pico (p)", questionText: "pico (p) = ?", answer: "10⁻¹²", distractors: ["10⁻⁹", "10⁻¹⁵", "10⁻⁶", "10¹²"], level: .ultimate),
        UnitConversionItem(key: "unit_124", expression: "hecto (h)", questionText: "hecto (h) = ?", answer: "10²", distractors: ["10¹", "10³", "10⁻²", "10⁶"], level: .ultimate),

        // Godlike (25): Physics, Temperature, Pressure & Energy
        UnitConversionItem(key: "unit_125", expression: "0 °C", questionText: "0 °C = ? K", answer: "273.15 K", distractors: ["173.15 K", "373.15 K", "0 K", "-273.15 K"], level: .godlike),
        UnitConversionItem(key: "unit_126", expression: "100 °C", questionText: "100 °C = ? K", answer: "373.15 K", distractors: ["273.15 K", "473.15 K", "173.15 K", "100 K"], level: .godlike),
        UnitConversionItem(key: "unit_127", expression: "-273.15 °C", questionText: "-273.15 °C = ? K", answer: "0 K", distractors: ["273.15 K", "-273.15 K", "100 K", "546.3 K"], level: .godlike),
        UnitConversionItem(key: "unit_128", expression: "20 °C", questionText: "20 °C = ? K", answer: "293.15 K", distractors: ["253.15 K", "273.15 K", "313.15 K", "220 K"], level: .godlike),
        UnitConversionItem(key: "unit_129", expression: "0 °C", questionText: "0 °C = ? °F", answer: "32 °F", distractors: ["0 °F", "100 °F", "212 °F", "273 °F"], level: .godlike),
        UnitConversionItem(key: "unit_130", expression: "100 °C", questionText: "100 °C = ? °F", answer: "212 °F", distractors: ["180 °F", "200 °F", "132 °F", "273 °F"], level: .godlike),
        UnitConversionItem(key: "unit_131", expression: "1 kJ", questionText: "1 kJ = ? J", answer: "1000 J", distractors: ["100 J", "10 000 J", "10 J", "3600 J"], level: .godlike),
        UnitConversionItem(key: "unit_132", expression: "1 MJ", questionText: "1 MJ = ? kJ", answer: "1000 kJ", distractors: ["100 kJ", "1 000 000 kJ", "10 kJ", "3600 kJ"], level: .godlike),
        UnitConversionItem(key: "unit_133", expression: "1 kWh", questionText: "1 kWh = ? MJ", answer: "3.6 MJ", distractors: ["1 MJ", "36 MJ", "0.36 MJ", "1000 MJ"], level: .godlike),
        UnitConversionItem(key: "unit_134", expression: "1 cal", questionText: "1 cal ≈ ? J", answer: "4.18 J", distractors: ["1.18 J", "2.41 J", "9.81 J", "41.8 J"], level: .godlike),
        UnitConversionItem(key: "unit_135", expression: "1 kcal", questionText: "1 kcal = ? cal", answer: "1000 cal", distractors: ["100 cal", "10 000 cal", "4180 cal", "10 cal"], level: .godlike),
        UnitConversionItem(key: "unit_136", expression: "1 kW", questionText: "1 kW = ? W", answer: "1000 W", distractors: ["100 W", "10 000 W", "746 W", "3600 W"], level: .godlike),
        UnitConversionItem(key: "unit_137", expression: "1 MW", questionText: "1 MW = ? kW", answer: "1000 kW", distractors: ["100 kW", "1 000 000 kW", "10 kW", "500 kW"], level: .godlike),
        UnitConversionItem(key: "unit_138", expression: "1 hPa", questionText: "1 hPa = ? Pa", answer: "100 Pa", distractors: ["10 Pa", "1000 Pa", "10 000 Pa", "0.01 Pa"], level: .godlike),
        UnitConversionItem(key: "unit_139", expression: "1 kPa", questionText: "1 kPa = ? Pa", answer: "1000 Pa", distractors: ["100 Pa", "10 Pa", "10 000 Pa", "100 000 Pa"], level: .godlike),
        UnitConversionItem(key: "unit_140", expression: "1 bar", questionText: "1 bar = ? kPa", answer: "100 kPa", distractors: ["10 kPa", "1000 kPa", "1 kPa", "10 000 kPa"], level: .godlike),
        UnitConversionItem(key: "unit_141", expression: "1 bar", questionText: "1 bar = ? hPa", answer: "1000 hPa", distractors: ["100 hPa", "10 000 hPa", "10 hPa", "100 000 hPa"], level: .godlike),
        UnitConversionItem(key: "unit_142", expression: "1 atm", questionText: "1 atm ≈ ? hPa", answer: "1013 hPa", distractors: ["1000 hPa", "100 hPa", "760 hPa", "10 130 hPa"], level: .godlike),
        UnitConversionItem(key: "unit_143", expression: "1 kHz", questionText: "1 kHz = ? Hz", answer: "1000 Hz", distractors: ["100 Hz", "10 000 Hz", "60 Hz", "1 000 000 Hz"], level: .godlike),
        UnitConversionItem(key: "unit_144", expression: "1 MHz", questionText: "1 MHz = ? kHz", answer: "1000 kHz", distractors: ["100 kHz", "1 000 000 kHz", "10 kHz", "500 kHz"], level: .godlike),
        UnitConversionItem(key: "unit_145", expression: "1 GHz", questionText: "1 GHz = ? MHz", answer: "1000 MHz", distractors: ["100 MHz", "1 000 000 MHz", "10 MHz", "1024 MHz"], level: .godlike),
        UnitConversionItem(key: "unit_146", expression: "1 kN", questionText: "1 kN = ? N", answer: "1000 N", distractors: ["100 N", "10 000 N", "9.81 N", "10 N"], level: .godlike),
        UnitConversionItem(key: "unit_147", expression: "1 mA", questionText: "1 mA = ? A", answer: "0.001 A", distractors: ["0.01 A", "0.1 A", "1000 A", "0.0001 A"], level: .godlike),
        UnitConversionItem(key: "unit_148", expression: "1 kV", questionText: "1 kV = ? V", answer: "1000 V", distractors: ["100 V", "10 000 V", "10 V", "0.001 V"], level: .godlike),
        UnitConversionItem(key: "unit_149", expression: "1 Å", questionText: "1 Å = ? m", answer: "10⁻¹⁰ m", distractors: ["10⁻⁹ m", "10⁻¹² m", "10⁻⁶ m", "10⁻⁸ m"], level: .godlike)
    ]

    func unitConversionPool(for level: GameLevel) -> [UnitConversionItem] {
        return allUnitConversionItems.filter { $0.level == level }
    }

    private func makeUnitConversionQuestion(from item: UnitConversionItem, maxTime: Double) -> Question {
        let options = makeStringOptions(correct: item.answer, distractors: item.distractors)
        let correctIdx = options.firstIndex(of: item.answer) ?? 0
        return Question(
            itemKey: item.key,
            text: item.questionText,
            subtext: NSLocalizedString("prompt_unit_convert", comment: "Convert units:"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime
        )
    }

    private func generateUnitConversions(level: GameLevel, maxTime: Double) -> Question {
        let pool = unitConversionPool(for: level)
        guard let item = pool.randomElement() else {
            return Question(text: "1 km = ? m", options: ["100 m", "1000 m", "10 m", "10 000 m"], correctIndex: 1, maxTime: maxTime)
        }
        return makeUnitConversionQuestion(from: item, maxTime: maxTime)
    }

    // MARK: - 21. Chemical Compounds & Formulas
    let allCompounds: [CompoundInfo] = [
        // 0..<20: Everyday molecules & common substances (Beginner)
        CompoundInfo(formula: "H₂O", key: "water", names: ["en": "Water", "pl": "Woda", "de": "Wasser", "es": "Agua", "fr": "Eau", "he": "מים"]),
        CompoundInfo(formula: "O₂", key: "oxygen_gas", names: ["en": "Oxygen (gas)", "pl": "Tlen (cząsteczka)", "de": "Sauerstoff (Molekül)", "es": "Oxígeno (gas)", "fr": "Dioxygène", "he": "חמצן (מולקולה)"]),
        CompoundInfo(formula: "N₂", key: "nitrogen_gas", names: ["en": "Nitrogen (gas)", "pl": "Azot (cząsteczka)", "de": "Stickstoff (Molekül)", "es": "Nitrógeno (gas)", "fr": "Diazote", "he": "חנקן (מולקולה)"]),
        CompoundInfo(formula: "H₂", key: "hydrogen_gas", names: ["en": "Hydrogen (gas)", "pl": "Wodór (cząsteczka)", "de": "Wasserstoff (Molekül)", "es": "Hidrógeno (gas)", "fr": "Dihydrogène", "he": "מימן (מולקולה)"]),
        CompoundInfo(formula: "CO₂", key: "carbon_dioxide", names: ["en": "Carbon dioxide", "pl": "Dwutlenek węgla", "de": "Kohlenstoffdioxid", "es": "Dióxido de carbono", "fr": "Dioxyde de carbone", "he": "פחמן דו-חמצני"]),
        CompoundInfo(formula: "O₃", key: "ozone", names: ["en": "Ozone", "pl": "Ozon", "de": "Ozon", "es": "Ozono", "fr": "Ozone", "he": "אוזון"]),
        CompoundInfo(formula: "CH₄", key: "methane", names: ["en": "Methane", "pl": "Metan", "de": "Methan", "es": "Metano", "fr": "Méthane", "he": "מתאן"]),
        CompoundInfo(formula: "NH₃", key: "ammonia", names: ["en": "Ammonia", "pl": "Amoniak", "de": "Ammoniak", "es": "Amoníaco", "fr": "Ammoniac", "he": "אמוניה"]),
        CompoundInfo(formula: "NaCl", key: "sodium_chloride", names: ["en": "Sodium chloride (Salt)", "pl": "Chlorek sodu (Sól)", "de": "Natriumchlorid (Salz)", "es": "Cloruro de sodio (Sal)", "fr": "Chlorure de sodium (Sel)", "he": "נתרן כלורי (מלח)"]),
        CompoundInfo(formula: "H₂O₂", key: "hydrogen_peroxide", names: ["en": "Hydrogen peroxide", "pl": "Nadtlenek wodoru", "de": "Wasserstoffperoxid", "es": "Peróxido de hidrógeno", "fr": "Peroxyde d'hydrogène", "he": "מי חמצן"]),
        CompoundInfo(formula: "C₁₂H₂₂O₁₁", key: "sucrose", names: ["en": "Sucrose (Sugar)", "pl": "Sacharoza (Cukier)", "de": "Saccharose (Zucker)", "es": "Sacarosa (Azúcar)", "fr": "Saccharose (Sucre)", "he": "סוכרוז (סוכר)"]),
        CompoundInfo(formula: "C₆H₁₂O₆", key: "glucose", names: ["en": "Glucose", "pl": "Glukoza", "de": "Glucose", "es": "Glucosa", "fr": "Glucose", "he": "גלוקוז"]),
        CompoundInfo(formula: "C₂H₅OH", key: "ethanol", names: ["en": "Ethanol", "pl": "Etanol", "de": "Ethanol", "es": "Etanol", "fr": "Éthanol", "he": "אתנול"]),
        CompoundInfo(formula: "CaCO₃", key: "calcium_carbonate", names: ["en": "Calcium carbonate (Chalk)", "pl": "Węglan wapnia (Kreda)", "de": "Calciumcarbonat (Kalk)", "es": "Carbonato de calcio", "fr": "Carbonate de calcium", "he": "סידן פחמתי (גיר)"]),
        CompoundInfo(formula: "HCl", key: "hydrochloric_acid", names: ["en": "Hydrochloric acid", "pl": "Kwas solny", "de": "Salzsäure", "es": "Ácido clorhídrico", "fr": "Acide chlorhydrique", "he": "חומצה מלחית"]),
        CompoundInfo(formula: "H₂SO₄", key: "sulfuric_acid", names: ["en": "Sulfuric acid", "pl": "Kwas siarkowy(VI)", "de": "Schwefelsäure", "es": "Ácido sulfúrico", "fr": "Acide sulfurique", "he": "חומצה גופרתית"]),
        CompoundInfo(formula: "CO", key: "carbon_monoxide", names: ["en": "Carbon monoxide", "pl": "Tlenek węgla(II) (Czad)", "de": "Kohlenstoffmonoxid", "es": "Monóxido de carbono", "fr": "Monoxyde de carbone", "he": "פחמן חד-חמצני"]),
        CompoundInfo(formula: "Cl₂", key: "chlorine_gas", names: ["en": "Chlorine (gas)", "pl": "Chlor (cząsteczka)", "de": "Chlor (Molekül)", "es": "Cloro (gas)", "fr": "Dichlore", "he": "כלור (מולקולה)"]),
        CompoundInfo(formula: "SiO₂", key: "silicon_dioxide", names: ["en": "Silicon dioxide (Quartz)", "pl": "Dwutlenek krzemu (Kwarc)", "de": "Siliciumdioxid (Quarz)", "es": "Dióxido de silicio", "fr": "Dioxyde de silicium", "he": "צורן דו-חמצני"]),
        CompoundInfo(formula: "Fe₂O₃", key: "iron_iii_oxide", names: ["en": "Iron(III) oxide (Rust)", "pl": "Tlenek żelaza(III)", "de": "Eisen(III)-oxid", "es": "Óxido de hierro(III)", "fr": "Oxyde de fer(III)", "he": "תחמוצת ברזל(III)"]),

        // 20..<40: Simple oxides & hydrides (Easy / Medium)
        CompoundInfo(formula: "MgO", key: "magnesium_oxide", names: ["en": "Magnesium oxide", "pl": "Tlenek magnezu", "de": "Magnesiumoxid", "es": "Óxido de magnesio", "fr": "Oxyde de magnésium", "he": "תחמוצת מגנזיום"]),
        CompoundInfo(formula: "CaO", key: "calcium_oxide", names: ["en": "Calcium oxide (Quicklime)", "pl": "Tlenek wapnia", "de": "Calciumoxid", "es": "Óxido de calcio", "fr": "Oxyde de calcium", "he": "תחמוצת סידן"]),
        CompoundInfo(formula: "CuO", key: "copper_ii_oxide", names: ["en": "Copper(II) oxide", "pl": "Tlenek miedzi(II)", "de": "Kupfer(II)-oxid", "es": "Óxido de cobre(II)", "fr": "Oxyde de cuivre(II)", "he": "תחמוצת נחושת(II)"]),
        CompoundInfo(formula: "ZnO", key: "zinc_oxide", names: ["en": "Zinc oxide", "pl": "Tlenek cynku", "de": "Zinkoxid", "es": "Óxido de zinc", "fr": "Oxyde de zinc", "he": "תחמוצת אבץ"]),
        CompoundInfo(formula: "Al₂O₃", key: "aluminum_oxide", names: ["en": "Aluminum oxide", "pl": "Tlenek glinu", "de": "Aluminiumoxid", "es": "Óxido de aluminio", "fr": "Oxyde d'aluminium", "he": "תחמוצת אלומיניום"]),
        CompoundInfo(formula: "Na₂O", key: "sodium_oxide", names: ["en": "Sodium oxide", "pl": "Tlenek sodu", "de": "Natriumoxid", "es": "Óxido de sodio", "fr": "Oxyde de sodium", "he": "תחמוצת נתרן"]),
        CompoundInfo(formula: "K₂O", key: "potassium_oxide", names: ["en": "Potassium oxide", "pl": "Tlenek potasu", "de": "Kaliumoxid", "es": "Óxido de potasio", "fr": "Oxyde de potassium", "he": "תחמוצת אשלגן"]),
        CompoundInfo(formula: "SO₂", key: "sulfur_dioxide", names: ["en": "Sulfur dioxide", "pl": "Tlenek siarki(IV)", "de": "Schwefeldioxid", "es": "Dióxido de azufre", "fr": "Dioxyde de soufre", "he": "גופרית דו-חמצנית"]),
        CompoundInfo(formula: "SO₃", key: "sulfur_trioxide", names: ["en": "Sulfur trioxide", "pl": "Tlenek siarki(VI)", "de": "Schwefeltrioxid", "es": "Trióxido de azufre", "fr": "Trioxyde de soufre", "he": "גופרית תלת-חמצנית"]),
        CompoundInfo(formula: "NO", key: "nitric_oxide", names: ["en": "Nitric oxide", "pl": "Tlenek azotu(II)", "de": "Stickstoffmonoxid", "es": "Óxido nítrico", "fr": "Monoxyde d'azote", "he": "חנקן חד-חמצני"]),
        CompoundInfo(formula: "NO₂", key: "nitrogen_dioxide", names: ["en": "Nitrogen dioxide", "pl": "Tlenek azotu(IV)", "de": "Stickstoffdioxid", "es": "Dióxido de nitrógeno", "fr": "Dioxyde d'azote", "he": "חנקן דו-חמצני"]),
        CompoundInfo(formula: "N₂O", key: "nitrous_oxide", names: ["en": "Nitrous oxide", "pl": "Tlenek azotu(I)", "de": "Distickstoffmonoxid", "es": "Óxido nitroso", "fr": "Protoxyde d'azote", "he": "חמצן דו-חנקני"]),
        CompoundInfo(formula: "P₄O₁₀", key: "phosphorus_pentoxide", names: ["en": "Phosphorus pentoxide", "pl": "Tlenek fosforu(V)", "de": "Phosphorpentoxid", "es": "Pentóxido de fósforo", "fr": "Pentoxyde de phosphore", "he": "זרחן חמש-חמצני"]),
        CompoundInfo(formula: "H₂S", key: "hydrogen_sulfide", names: ["en": "Hydrogen sulfide", "pl": "Siarkowodór", "de": "Schwefelwasserstoff", "es": "Sulfuro de hidrógeno", "fr": "Sulfure d'hydrogène", "he": "מימן גופרי"]),
        CompoundInfo(formula: "HF", key: "hydrofluoric_acid", names: ["en": "Hydrogen fluoride", "pl": "Fluorowodór", "de": "Fluorwasserstoff", "es": "Fluoruro de hidrógeno", "fr": "Fluorure d'hydrogène", "he": "מימן פלואורי"]),
        CompoundInfo(formula: "HBr", key: "hydrogen_bromide", names: ["en": "Hydrogen bromide", "pl": "Bromowodór", "de": "Bromwasserstoff", "es": "Bromuro de hidrógeno", "fr": "Bromure d'hydrogène", "he": "מימן ברומי"]),
        CompoundInfo(formula: "HI", key: "hydrogen_iodide", names: ["en": "Hydrogen iodide", "pl": "Jodowodór", "de": "Iodwasserstoff", "es": "Yoduro de hidrógeno", "fr": "Iodure d'hydrogène", "he": "מימן יודי"]),
        CompoundInfo(formula: "PH₃", key: "phosphine", names: ["en": "Phosphine", "pl": "Fosfina", "de": "Phosphan", "es": "Fosfina", "fr": "Phosphine", "he": "פוספין"]),
        CompoundInfo(formula: "SiH₄", key: "silane", names: ["en": "Silane", "pl": "Silan", "de": "Monosilan", "es": "Silano", "fr": "Silane", "he": "סילאן"]),
        CompoundInfo(formula: "BaO", key: "barium_oxide", names: ["en": "Barium oxide", "pl": "Tlenek baru", "de": "Bariumoxid", "es": "Óxido de bario", "fr": "Oxyde de baryum", "he": "תחמוצת בריום"]),

        // 40..<60: Common acids & hydroxides/bases (Medium / Hard)
        CompoundInfo(formula: "HNO₃", key: "nitric_acid", names: ["en": "Nitric acid", "pl": "Kwas azotowy(V)", "de": "Salpetersäure", "es": "Ácido nítrico", "fr": "Acide nitrique", "he": "חומצה חנקתית"]),
        CompoundInfo(formula: "H₃PO₄", key: "phosphoric_acid", names: ["en": "Phosphoric acid", "pl": "Kwas fosforowy(V)", "de": "Phosphorsäure", "es": "Ácido fosfórico", "fr": "Acide phosphorique", "he": "חומצה זרחתית"]),
        CompoundInfo(formula: "H₂CO₃", key: "carbonic_acid", names: ["en": "Carbonic acid", "pl": "Kwas węglowy", "de": "Kohlensäure", "es": "Ácido carbónico", "fr": "Acide carbonique", "he": "חומצה פחמתית"]),
        CompoundInfo(formula: "H₂SO₃", key: "sulfurous_acid", names: ["en": "Sulfurous acid", "pl": "Kwas siarkowy(IV)", "de": "Schweflige Säure", "es": "Ácido sulfuroso", "fr": "Acide sulfureux", "he": "חומצה גופריתית"]),
        CompoundInfo(formula: "HNO₂", key: "nitrous_acid", names: ["en": "Nitrous acid", "pl": "Kwas azotowy(III)", "de": "Salpetrige Säure", "es": "Ácido nitroso", "fr": "Acide nitreux", "he": "חומצה חנקיתית"]),
        CompoundInfo(formula: "HClO₄", key: "perchloric_acid", names: ["en": "Perchloric acid", "pl": "Kwas chlorowy(VII)", "de": "Perchlorsäure", "es": "Ácido perclórico", "fr": "Acide perchlorique", "he": "חומצה על-כלורית"]),
        CompoundInfo(formula: "CH₃COOH", key: "acetic_acid", names: ["en": "Acetic acid", "pl": "Kwas octowy", "de": "Essigsäure", "es": "Ácido acético", "fr": "Acide acétique", "he": "חומצה אצטית"]),
        CompoundInfo(formula: "HCOOH", key: "formic_acid", names: ["en": "Formic acid", "pl": "Kwas mrówkowy", "de": "Ameisensäure", "es": "Ácido fórmico", "fr": "Acide formique", "he": "חומצת נמלים"]),
        CompoundInfo(formula: "NaOH", key: "sodium_hydroxide", names: ["en": "Sodium hydroxide", "pl": "Wodorotlenek sodu", "de": "Natriumhydroxid", "es": "Hidróxido de sodio", "fr": "Hydroxyde de sodium", "he": "נתרן הידרוקסידי"]),
        CompoundInfo(formula: "KOH", key: "potassium_hydroxide", names: ["en": "Potassium hydroxide", "pl": "Wodorotlenek potasu", "de": "Kaliumhydroxid", "es": "Hidróxido de potasio", "fr": "Hydroxyde de potassium", "he": "אשלגן הידרוקסידי"]),
        CompoundInfo(formula: "Ca(OH)₂", key: "calcium_hydroxide", names: ["en": "Calcium hydroxide", "pl": "Wodorotlenek wapnia", "de": "Calciumhydroxid", "es": "Hidróxido de calcio", "fr": "Hydroxyde de calcium", "he": "סידן הידרוקסידי"]),
        CompoundInfo(formula: "Mg(OH)₂", key: "magnesium_hydroxide", names: ["en": "Magnesium hydroxide", "pl": "Wodorotlenek magnezu", "de": "Magnesiumhydroxid", "es": "Hidróxido de magnesio", "fr": "Hydroxyde de magnésium", "he": "מגנזיום הידרוקסידי"]),
        CompoundInfo(formula: "Ba(OH)₂", key: "barium_hydroxide", names: ["en": "Barium hydroxide", "pl": "Wodorotlenek baru", "de": "Bariumhydroxid", "es": "Hidróxido de bario", "fr": "Hydroxyde de baryum", "he": "בריום הידרוקסידי"]),
        CompoundInfo(formula: "Al(OH)₃", key: "aluminum_hydroxide", names: ["en": "Aluminum hydroxide", "pl": "Wodorotlenek glinu", "de": "Aluminiumhydroxid", "es": "Hidróxido de aluminio", "fr": "Hydroxyde d'aluminium", "he": "אלומיניום הידרוקסידי"]),
        CompoundInfo(formula: "Fe(OH)₃", key: "iron_iii_hydroxide", names: ["en": "Iron(III) hydroxide", "pl": "Wodorotlenek żelaza(III)", "de": "Eisen(III)-hydroxid", "es": "Hidróxido de hierro(III)", "fr": "Hydroxyde de fer(III)", "he": "ברזל(III) הידרוקסיד"]),
        CompoundInfo(formula: "Fe(OH)₂", key: "iron_ii_hydroxide", names: ["en": "Iron(II) hydroxide", "pl": "Wodorotlenek żelaza(II)", "de": "Eisen(II)-hydroxid", "es": "Hidróxido de hierro(II)", "fr": "Hydroxyde de fer(II)", "he": "ברזל(II) הידרוקסיד"]),
        CompoundInfo(formula: "Cu(OH)₂", key: "copper_ii_hydroxide", names: ["en": "Copper(II) hydroxide", "pl": "Wodorotlenek miedzi(II)", "de": "Kupfer(II)-hydroxid", "es": "Hidróxido de cobre(II)", "fr": "Hydroxyde de cuivre(II)", "he": "נחושת(II) הידרוקסיד"]),
        CompoundInfo(formula: "Zn(OH)₂", key: "zinc_hydroxide", names: ["en": "Zinc hydroxide", "pl": "Wodorotlenek cynku", "de": "Zinkhydroxid", "es": "Hidróxido de zinc", "fr": "Hydroxyde de zinc", "he": "אבץ הידרוקסידי"]),
        CompoundInfo(formula: "LiOH", key: "lithium_hydroxide", names: ["en": "Lithium hydroxide", "pl": "Wodorotlenek litu", "de": "Lithiumhydroxid", "es": "Hidróxido de litio", "fr": "Hydroxyde de lithium", "he": "ליתיום הידרוקסידי"]),
        CompoundInfo(formula: "NH₄OH", key: "ammonium_hydroxide", names: ["en": "Ammonium hydroxide", "pl": "Woda amoniakalna", "de": "Ammoniakwasser", "es": "Hidróxido de amonio", "fr": "Hydroxyde d'ammonium", "he": "מי אמוניה"]),

        // 60..<80: Inorganic salts & minerals (Hard / Ultimate)
        CompoundInfo(formula: "NaHCO₃", key: "sodium_bicarbonate", names: ["en": "Sodium bicarbonate (Baking soda)", "pl": "Wodorowęglan sodu (Soda)", "de": "Natriumhydrogencarbonat", "es": "Bicarbonato de sodio", "fr": "Bicarbonate de sodium", "he": "סודה לשתייה"]),
        CompoundInfo(formula: "Na₂CO₃", key: "sodium_carbonate", names: ["en": "Sodium carbonate", "pl": "Węglan sodu", "de": "Natriumcarbonat", "es": "Carbonato de sodio", "fr": "Carbonate de sodium", "he": "נתרן פחמתי"]),
        CompoundInfo(formula: "K₂CO₃", key: "potassium_carbonate", names: ["en": "Potassium carbonate", "pl": "Węglan potasu", "de": "Kaliumcarbonat", "es": "Carbonato de potasio", "fr": "Carbonate de potassium", "he": "אשלגן פחמתי"]),
        CompoundInfo(formula: "MgCO₃", key: "magnesium_carbonate", names: ["en": "Magnesium carbonate", "pl": "Węglan magnezu", "de": "Magnesiumcarbonat", "es": "Carbonato de magnesio", "fr": "Carbonate de magnésium", "he": "מגנזיום פחמתי"]),
        CompoundInfo(formula: "CuSO₄", key: "copper_sulfate", names: ["en": "Copper(II) sulfate", "pl": "Siarczan(VI) miedzi(II)", "de": "Kupfer(II)-sulfat", "es": "Sulfato de cobre(II)", "fr": "Sulfate de cuivre(II)", "he": "נחושת גופרתית"]),
        CompoundInfo(formula: "FeSO₄", key: "iron_ii_sulfate", names: ["en": "Iron(II) sulfate", "pl": "Siarczan(VI) żelaza(II)", "de": "Eisen(II)-sulfat", "es": "Sulfato de hierro(II)", "fr": "Sulfate de fer(II)", "he": "ברזל(II) גופרתי"]),
        CompoundInfo(formula: "ZnSO₄", key: "zinc_sulfate", names: ["en": "Zinc sulfate", "pl": "Siarczan(VI) cynku", "de": "Zinksulfat", "es": "Sulfato de zinc", "fr": "Sulfate de zinc", "he": "אבץ גופרתי"]),
        CompoundInfo(formula: "BaSO₄", key: "barium_sulfate", names: ["en": "Barium sulfate", "pl": "Siarczan(VI) baru", "de": "Bariumsulfat", "es": "Sulfato de bario", "fr": "Sulfate de baryum", "he": "בריום גופרתי"]),
        CompoundInfo(formula: "CaSO₄", key: "calcium_sulfate", names: ["en": "Calcium sulfate (Gypsum)", "pl": "Siarczan(VI) wapnia (Gips)", "de": "Calciumsulfat (Gips)", "es": "Sulfato de calcio (Yeso)", "fr": "Sulfate de calcium (Gypse)", "he": "סידן גופרתי (גבס)"]),
        CompoundInfo(formula: "Na₂SO₄", key: "sodium_sulfate", names: ["en": "Sodium sulfate", "pl": "Siarczan(VI) sodu", "de": "Natriumsulfat", "es": "Sulfato de sodio", "fr": "Sulfate de sodium", "he": "נתרן גופרתי"]),
        CompoundInfo(formula: "AgNO₃", key: "silver_nitrate", names: ["en": "Silver nitrate", "pl": "Azotan(V) srebra(I)", "de": "Silbernitrat", "es": "Nitrato de plata", "fr": "Nitrate d'argent", "he": "כסף חנקתי"]),
        CompoundInfo(formula: "KNO₃", key: "potassium_nitrate", names: ["en": "Potassium nitrate", "pl": "Azotan(V) potasu", "de": "Kaliumnitrat", "es": "Nitrato de potasio", "fr": "Nitrate de potassium", "he": "אשלגן חנקתי"]),
        CompoundInfo(formula: "NaNO₃", key: "sodium_nitrate", names: ["en": "Sodium nitrate", "pl": "Azotan(V) sodu", "de": "Natriumnitrat", "es": "Nitrato de sodio", "fr": "Nitrate de sodium", "he": "נתרן חנקתי"]),
        CompoundInfo(formula: "NH₄NO₃", key: "ammonium_nitrate", names: ["en": "Ammonium nitrate", "pl": "Azotan(V) amonu", "de": "Ammoniumnitrat", "es": "Nitrato de amonio", "fr": "Nitrate d'ammonium", "he": "אמוניום חנקתי"]),
        CompoundInfo(formula: "CaCl₂", key: "calcium_chloride", names: ["en": "Calcium chloride", "pl": "Chlorek wapnia", "de": "Calciumchlorid", "es": "Cloruro de calcio", "fr": "Chlorure de calcium", "he": "סידן כלורי"]),
        CompoundInfo(formula: "MgCl₂", key: "magnesium_chloride", names: ["en": "Magnesium chloride", "pl": "Chlorek magnezu", "de": "Magnesiumchlorid", "es": "Cloruro de magnesio", "fr": "Chlorure de magnésium", "he": "מגנזיום כלורי"]),
        CompoundInfo(formula: "FeCl₃", key: "iron_iii_chloride", names: ["en": "Iron(III) chloride", "pl": "Chlorek żelaza(III)", "de": "Eisen(III)-chlorid", "es": "Cloruro de hierro(III)", "fr": "Chlorure de fer(III)", "he": "ברזל(III) כלורי"]),
        CompoundInfo(formula: "AlCl₃", key: "aluminum_chloride", names: ["en": "Aluminum chloride", "pl": "Chlorek glinu", "de": "Aluminiumchlorid", "es": "Cloruro de aluminio", "fr": "Chlorure d'aluminium", "he": "אלומיניום כלורי"]),
        CompoundInfo(formula: "NH₄Cl", key: "ammonium_chloride", names: ["en": "Ammonium chloride", "pl": "Chlorek amonu", "de": "Ammoniumchlorid", "es": "Cloruro de amonio", "fr": "Chlorure d'ammonium", "he": "אמוניום כלורי"]),
        CompoundInfo(formula: "KMnO₄", key: "potassium_permanganate", names: ["en": "Potassium permanganate", "pl": "Manganian(VII) potasu", "de": "Kaliumpermanganat", "es": "Permanganato de potasio", "fr": "Permanganate de potassium", "he": "אשלגן פרמנגנט"]),

        // 80..<95: Organic chemistry (Ultimate / Godlike)
        CompoundInfo(formula: "C₂H₆", key: "ethane", names: ["en": "Ethane", "pl": "Etan", "de": "Ethan", "es": "Etano", "fr": "Éthane", "he": "אתאן"]),
        CompoundInfo(formula: "C₃H₈", key: "propane", names: ["en": "Propane", "pl": "Propan", "de": "Propan", "es": "Propano", "fr": "Propane", "he": "פרופאן"]),
        CompoundInfo(formula: "C₄H₁₀", key: "butane", names: ["en": "Butane", "pl": "Butan", "de": "Butan", "es": "Butano", "fr": "Butane", "he": "בוטאן"]),
        CompoundInfo(formula: "C₂H₄", key: "ethene", names: ["en": "Ethene (Ethylene)", "pl": "Eten (Etylen)", "de": "Ethen (Ethylen)", "es": "Eteno (Etileno)", "fr": "Éthène (Éthylène)", "he": "אתן (אתילן)"]),
        CompoundInfo(formula: "C₂H₂", key: "ethyne", names: ["en": "Ethyne (Acetylene)", "pl": "Etyn (Acetylen)", "de": "Ethin (Acetylen)", "es": "Etino (Acetileno)", "fr": "Éthyne (Acétylène)", "he": "אתין (אצטילן)"]),
        CompoundInfo(formula: "C₆H₆", key: "benzene", names: ["en": "Benzene", "pl": "Benzen", "de": "Benzol", "es": "Benceno", "fr": "Benzène", "he": "בנזן"]),
        CompoundInfo(formula: "CH₃OH", key: "methanol", names: ["en": "Methanol", "pl": "Metanol", "de": "Methanol", "es": "Metanol", "fr": "Méthanol", "he": "מתנול"]),
        CompoundInfo(formula: "C₃H₇OH", key: "propanol", names: ["en": "Propanol", "pl": "Propanol", "de": "Propanol", "es": "Propanol", "fr": "Propanol", "he": "פרופנול"]),
        CompoundInfo(formula: "HCHO", key: "formaldehyde", names: ["en": "Formaldehyde (Methanal)", "pl": "Metanal (Formaldehyd)", "de": "Methanal (Formaldehyd)", "es": "Metanal (Formaldehído)", "fr": "Méthanal (Formaldéhyde)", "he": "פורמלדהיד"]),
        CompoundInfo(formula: "CH₃CHO", key: "acetaldehyde", names: ["en": "Acetaldehyde (Ethanal)", "pl": "Etanal (Aldehyd octowy)", "de": "Ethanal (Acetaldehyd)", "es": "Etanal (Acetaldehído)", "fr": "Éthanal (Acétaldéhyde)", "he": "אצטלדהיד"]),
        CompoundInfo(formula: "CH₃COCH₃", key: "acetone", names: ["en": "Acetone", "pl": "Aceton", "de": "Aceton", "es": "Acetona", "fr": "Acétone", "he": "אצטון"]),
        CompoundInfo(formula: "C₃H₅(OH)₃", key: "glycerol", names: ["en": "Glycerol", "pl": "Glicerol (Gliceryna)", "de": "Glycerin", "es": "Glicerol", "fr": "Glycérol", "he": "גליצרול"]),
        CompoundInfo(formula: "C₁₇H₃₅COOH", key: "stearic_acid", names: ["en": "Stearic acid", "pl": "Kwas stearynowy", "de": "Stearinsäure", "es": "Ácido esteárico", "fr": "Acide stéarique", "he": "חומצה סטארית"]),
        CompoundInfo(formula: "CH₃COOC₂H₅", key: "ethyl_acetate", names: ["en": "Ethyl acetate", "pl": "Octan etylu", "de": "Ethylacetat", "es": "Acetato de etilo", "fr": "Acétate d'éthyle", "he": "אתיל אצטט"]),
        CompoundInfo(formula: "CO(NH₂)₂", key: "urea", names: ["en": "Urea", "pl": "Mocznik", "de": "Harnstoff", "es": "Urea", "fr": "Urée", "he": "אוראה"]),

        // 95..<100: Complex polyatomic inorganic compounds (Godlike)
        CompoundInfo(formula: "K₂Cr₂O₇", key: "potassium_dichromate", names: ["en": "Potassium dichromate", "pl": "Dichromian(VI) potasu", "de": "Kaliumdichromat", "es": "Dicromato de potasio", "fr": "Dichromate de potassium", "he": "אשלגן דיכרומט"]),
        CompoundInfo(formula: "K₂CrO₄", key: "potassium_chromate", names: ["en": "Potassium chromate", "pl": "Chromian(VI) potasu", "de": "Kaliumchromat", "es": "Cromato de potasio", "fr": "Chromate de potassium", "he": "אשלגן כרומט"]),
        CompoundInfo(formula: "K₃[Fe(CN)₆]", key: "potassium_ferricyanide", names: ["en": "Potassium ferricyanide", "pl": "Heksacyjanożelazian(III) potasu", "de": "Kaliumhexacyanoferrat(III)", "es": "Ferricianuro de potasio", "fr": "Ferricyanure de potassium", "he": "אשלגן פריציאניד"]),
        CompoundInfo(formula: "Na₂S₂O₃", key: "sodium_thiosulfate", names: ["en": "Sodium thiosulfate", "pl": "Tiosiarczan sodu", "de": "Natriumthiosulfat", "es": "Tiosulfato de sodio", "fr": "Thiosulfate de sodium", "he": "נתרן תיוסולפט"]),
        CompoundInfo(formula: "Ca₃(PO₄)₂", key: "calcium_phosphate", names: ["en": "Calcium phosphate", "pl": "Fosforan(V) wapnia", "de": "Calciumphosphat", "es": "Fosfato de calcio", "fr": "Phosphate de calcium", "he": "סידן זרחתי"])
    ]

    func compoundsPool(for level: GameLevel) -> [CompoundInfo] {
        let total = allCompounds.count
        guard total > 0 else { return [] }
        let range: Range<Int>
        switch level {
        case .beginner: range = 0..<min(20, total)
        case .easy: range = 0..<min(40, total)
        case .medium: range = min(20, total - 1)..<min(60, total)
        case .hard: range = min(40, total - 1)..<min(80, total)
        case .ultimate: range = min(60, total - 1)..<min(95, total)
        case .godlike: range = min(70, total - 1)..<total
        }
        return Array(allCompounds[range])
    }

    private func makeCompoundQuestion(target: CompoundInfo, level: GameLevel, maxTime: Double, askForName: Bool = Bool.random()) -> Question {
        let pool = compoundsPool(for: level)
        let itemKey = "comp_\(target.formula)"
        let localizedTarget = localizedCompoundName(for: target)

        var distractors: [CompoundInfo] = [target]
        var usedNames = Set<String>([localizedTarget])
        for candidate in pool.shuffled() where candidate.formula != target.formula {
            if distractors.count >= 4 { break }
            let candidateName = localizedCompoundName(for: candidate)
            if !distractors.contains(where: { $0.formula == candidate.formula }) && !usedNames.contains(candidateName) {
                distractors.append(candidate)
                usedNames.insert(candidateName)
            }
        }
        for candidate in allCompounds.shuffled() where candidate.formula != target.formula {
            if distractors.count >= 4 { break }
            let candidateName = localizedCompoundName(for: candidate)
            if !distractors.contains(where: { $0.formula == candidate.formula }) && !usedNames.contains(candidateName) {
                distractors.append(candidate)
                usedNames.insert(candidateName)
            }
        }
        distractors.shuffle()

        if askForName {
            let options = distractors.map { localizedCompoundName(for: $0) }
            let correctIdx = options.firstIndex(of: localizedTarget) ?? 0
            return Question(
                itemKey: itemKey,
                text: target.formula,
                subtext: NSLocalizedString("prompt_chem_compound_name", comment: "What chemical compound is this?"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        } else {
            let options = distractors.map { $0.formula }
            let correctIdx = options.firstIndex(of: target.formula) ?? 0
            return Question(
                itemKey: itemKey,
                text: localizedTarget,
                subtext: NSLocalizedString("prompt_chem_compound_formula", comment: "What is the formula for:"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateChemCompounds(level: GameLevel, maxTime: Double) -> Question {
        let pool = compoundsPool(for: level)
        guard let target = pool.randomElement() ?? allCompounds.first else {
            return Question(text: "H₂O", options: ["Water", "Oxygen", "Hydrogen", "Ozone"], correctIndex: 0, maxTime: maxTime)
        }
        return makeCompoundQuestion(target: target, level: level, maxTime: maxTime)
    }

    private func makeStringOptions(correct: String, distractors: [String]) -> [String] {
        var set = Set<String>([correct])
        for cand in distractors.shuffled() {
            if set.count >= 4 { break }
            if cand != correct && !cand.isEmpty {
                set.insert(cand)
            }
        }
        var suffix = 1
        while set.count < 4 {
            let fallback = "\(correct) (\(suffix))"
            if !set.contains(fallback) {
                set.insert(fallback)
            }
            suffix += 1
        }
        return Array(set).shuffled()
    }

    // Helper: generate 4 unique numeric choices using multiple anti-meta-gaming strategies
    private func makeNumericOptions(
        correct: Int,
        range: Int = 10,
        minVal: Int = 0,
        maxVal: Int? = nil,
        contextCandidates: [Int] = [],
        allowNegative: Bool = false
    ) -> [String] {
        var set = Set<Int>([correct])

        // 1. Context candidates (domain-specific errors: intermediate results, wrong operator, other variable, etc.)
        let validContextCandidates = contextCandidates.filter { cand in
            cand != correct &&
            (allowNegative || cand >= minVal) &&
            (maxVal == nil || cand <= (maxVal ?? Int.max))
        }.shuffled()

        // Take 1 to 2 context candidates randomly to ensure different questions get different combinations
        if !validContextCandidates.isEmpty {
            let numToTake = Int.random(in: 1...min(2, validContextCandidates.count))
            for cand in validContextCandidates.prefix(numToTake) {
                set.insert(cand)
            }
        }

        // 2. Multi-Strategy Candidate Pools:
        // Strategy A: Same Last Digit (neutralizes the "last digit exploit" for math games)
        let step10 = max(10, (abs(correct) >= 100 ? 10 : (abs(correct) >= 20 ? 10 : 5)))
        var sameLastDigit: [Int] = []
        for mul in [1, -1, 2, -2, 10, -10] {
            let val = correct + (mul * step10)
            if val != correct && (allowNegative || val >= minVal) && (maxVal == nil || val <= (maxVal ?? Int.max)) {
                sameLastDigit.append(val)
            }
        }

        // Strategy B: Carry / Borrow / Small offset errors
        var carryErrors: [Int] = []
        for off in [1, -1, 2, -2, 9, -9, 11, -11] {
            let val = correct + off
            if val != correct && (allowNegative || val >= minVal) && (maxVal == nil || val <= (maxVal ?? Int.max)) {
                carryErrors.append(val)
            }
        }

        // Strategy C: Proportional scale offset
        let scale = max(1, abs(correct) / 10)
        var scaleErrors: [Int] = []
        for mul in [1, -1, 2, -2, 3, -3] {
            let val = correct + (mul * scale)
            if val != correct && (allowNegative || val >= minVal) && (maxVal == nil || val <= (maxVal ?? Int.max)) {
                scaleErrors.append(val)
            }
        }

        // Strategy D: Digit transposition
        var transpositionErrors: [Int] = []
        let absStr = "\(abs(correct))"
        if absStr.count >= 2 {
            var chars = Array(absStr)
            chars.swapAt(chars.count - 1, chars.count - 2)
            if let val = Int(String(chars)), val != abs(correct) {
                let signedVal = correct < 0 ? -val : val
                if (allowNegative || signedVal >= minVal) && (maxVal == nil || signedVal <= (maxVal ?? Int.max)) {
                    transpositionErrors.append(signedVal)
                }
            }
        }

        // Shuffle strategy pools to guarantee varied mixes on each question
        let strategyPools: [[Int]] = [
            sameLastDigit.shuffled(),
            carryErrors.shuffled(),
            scaleErrors.shuffled(),
            transpositionErrors.shuffled(),
            Array(validContextCandidates.dropFirst(2)).shuffled()
        ].shuffled()

        // Round-robin selection across different strategy pools
        for pool in strategyPools {
            if set.count >= 4 { break }
            for cand in pool {
                if !set.contains(cand) {
                    set.insert(cand)
                    break
                }
            }
        }

        // 3. Fallback to guarantee exactly 4 unique choices
        var delta = 1
        while set.count < 4 {
            let offset = (Bool.random() ? 1 : -1) * (delta + Int.random(in: 0...2))
            let val = correct + offset
            if (allowNegative || val >= minVal) && (maxVal == nil || val <= (maxVal ?? Int.max)) && val != correct {
                set.insert(val)
            }
            delta += 2
            if delta > 200 && maxVal != nil {
                for v in minVal...maxVal! {
                    if v != correct { set.insert(v) }
                    if set.count >= 4 { break }
                }
                break
            }
        }

        return set.map { "\($0)" }.shuffled()
    }

    // MARK: - Pre-generate 15 Unique Questions for Game Session
    // MARK: - Item Keys for a Level (used for per-level progress display)
    func itemKeysForLevel(gameType: GameType, level: GameLevel) -> [String] {
        if gameType == .flags {
            let totalCount = allCountries.count
            guard totalCount > 0 else { return [] }
            let range: Range<Int>
            switch level {
            case .beginner: range = 0..<min(25, totalCount)
            case .easy: range = 0..<min(55, totalCount)
            case .medium: range = min(25, totalCount - 1)..<min(80, totalCount)
            case .hard: range = min(50, totalCount - 1)..<min(120, totalCount)
            case .ultimate: range = min(80, totalCount - 1)..<min(160, totalCount)
            case .godlike: range = min(100, totalCount - 1)..<totalCount
            }
            return range.map { "country_\(allCountries[$0])" }
        } else if gameType == .capitals {
            return capitalsPool(for: level).map { "city_\(capitalCity(for: $0))" }
        } else if gameType == .chemSymbols || gameType == .chemNames {
            let total = allElements.count
            guard total > 0 else { return [] }
            let range: Range<Int>
            switch level {
            case .beginner: range = 0..<min(25, total)
            case .easy: range = 0..<min(50, total)
            case .medium: range = min(20, total - 1)..<min(70, total)
            case .hard: range = min(40, total - 1)..<min(95, total)
            case .ultimate: range = min(60, total - 1)..<min(105, total)
            case .godlike: range = min(70, total - 1)..<total
            }
            return range.map { "chem_\(allElements[$0].symbol)" }
        } else if gameType == .addition {
            if level == .beginner {
                var keys: [String] = []
                for a in 1...5 {
                    for b in 1...5 {
                        keys.append("math_add_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for a in 1...10 {
                    for b in 1...10 {
                        keys.append("math_add_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .subtraction {
            if level == .beginner {
                var keys: [String] = []
                for diff in 1...5 {
                    for b in 1...5 {
                        let a = b + diff
                        keys.append("math_sub_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for diff in 1...10 {
                    for b in 1...10 {
                        let a = b + diff
                        keys.append("math_sub_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .multiplication {
            if level == .beginner {
                var keys: [String] = []
                for a in 1...5 {
                    for b in 1...5 {
                        keys.append("math_mult_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for a in 1...10 {
                    for b in 1...10 {
                        keys.append("math_mult_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .division {
            if level == .beginner {
                var keys: [String] = []
                for q in 1...5 {
                    for b in 1...5 {
                        let a = b * q
                        keys.append("math_div_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for q in 1...10 {
                    for b in 1...10 {
                        let a = b * q
                        keys.append("math_div_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .romanNumerals {
            return romanPool(for: level).map { "roman_\($0)" }
        } else if gameType == .powersRoots {
            return powerRootPool(for: level).map { $0.key }
        } else if gameType == .fractions {
            return fractionPool(for: level).map { $0.key }
        } else if gameType == .unitConversions {
            return unitConversionPool(for: level).map { $0.key }
        } else if gameType == .chemCompounds {
            return compoundsPool(for: level).map { "comp_\($0.formula)" }
        }
        return []
    }

    func generateGameQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int = 15) -> [Question] {
        let maxTime = getMaxTime(for: level)

        switch gameType {
        case .flags:
            return generateFlagsQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .capitals:
            return generateCapitalsQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .chemSymbols:
            return generateChemSymbolsQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .chemNames:
            return generateChemNamesQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .romanNumerals:
            if level == .godlike {
                return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            }
            let selected = selectPrioritizedItems(romanPool(for: level), keyForItem: { "roman_\($0)" }, playerID: playerID, count: count)
            return selected.map { makeRomanQuestion(number: $0, level: level, maxTime: maxTime) }
        case .powersRoots:
            if level == .godlike {
                return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            }
            let selected = selectPrioritizedItems(powerRootPool(for: level), keyForItem: { $0.key }, playerID: playerID, count: count)
            return selected.map { makePowerRootQuestion(from: $0, maxTime: maxTime) }
        case .fractions:
            if level == .godlike {
                return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            }
            let selected = selectPrioritizedItems(fractionPool(for: level), keyForItem: { $0.key }, playerID: playerID, count: count)
            return selected.map { makeFractionQuestion(from: $0, maxTime: maxTime) }
        case .unitConversions:
            let selected = selectPrioritizedItems(unitConversionPool(for: level), keyForItem: { $0.key }, playerID: playerID, count: count)
            return selected.map { makeUnitConversionQuestion(from: $0, maxTime: maxTime) }
        case .chemCompounds:
            let selected = selectPrioritizedItems(compoundsPool(for: level), keyForItem: { "comp_\($0.formula)" }, playerID: playerID, count: count)
            return selected.map { makeCompoundQuestion(target: $0, level: level, maxTime: maxTime) }
        case .addition, .subtraction, .multiplication, .division:
            if level == .beginner || level == .easy {
                return generateMathProgressQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            } else {
                return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            }
        default:
            return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
        }
    }

    private func selectPrioritizedItems<T>(_ items: [T], keyForItem: (T) -> String, playerID: String, count: Int) -> [T] {
        guard !items.isEmpty else { return [] }
        var priority1: [T] = []
        var priority2: [T] = []
        for item in items {
            let status = ItemProgressTracker.shared.getStatus(for: keyForItem(item), playerID: playerID)
            if status == .correct {
                priority2.append(item)
            } else {
                priority1.append(item)
            }
        }
        priority1.shuffle()
        priority2.shuffle()

        var selected: [T] = []
        selected.append(contentsOf: priority1.prefix(count))
        if selected.count < count {
            selected.append(contentsOf: priority2.prefix(count - selected.count))
        }
        while selected.count < count {
            if let rand = items.randomElement() {
                selected.append(rand)
            }
        }
        return selected.shuffled()
    }

    private func generateCapitalsQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let availableCountries = capitalsPool(for: level)
        guard !availableCountries.isEmpty else { return [] }

        var priority1: [String] = []
        var priority2: [String] = []

        for country in availableCountries {
            let capital = capitalCity(for: country)
            let key = "city_\(capital)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(country)
            } else {
                priority1.append(country)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedCountries: [String] = []
        selectedCountries.append(contentsOf: priority1.prefix(count))
        if selectedCountries.count < count {
            let needed = count - selectedCountries.count
            selectedCountries.append(contentsOf: priority2.prefix(needed))
        }

        if selectedCountries.count < count {
            let remaining = availableCountries.filter { !selectedCountries.contains($0) }.shuffled()
            selectedCountries.append(contentsOf: remaining.prefix(count - selectedCountries.count))
        }

        while selectedCountries.count < count {
            if let rand = availableCountries.randomElement() {
                selectedCountries.append(rand)
            }
        }

        selectedCountries.shuffle()

        return selectedCountries.map { country in
            makeCapitalQuestion(
                targetCountry: country,
                level: level,
                maxTime: maxTime,
                askForCapital: Bool.random()
            )
        }
    }

    private func generateFlagsQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let totalCount = allCountries.count
        guard totalCount > 0 else { return [] }

        let availableIndices: [Int]
        switch level {
        case .beginner: availableIndices = Array(0..<min(25, totalCount))
        case .easy: availableIndices = Array(0..<min(55, totalCount))
        case .medium: availableIndices = Array(min(25, totalCount - 1)..<min(80, totalCount))
        case .hard: availableIndices = Array(min(50, totalCount - 1)..<min(120, totalCount))
        case .ultimate: availableIndices = Array(min(80, totalCount - 1)..<min(160, totalCount))
        case .godlike: availableIndices = Array(min(100, totalCount - 1)..<totalCount)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in availableIndices {
            let country = allCountries[idx]
            let key = "country_\(country)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = availableIndices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let rawTargetCountry = allCountries[idx]
            let itemKey = "country_\(rawTargetCountry)"
            let flagAssetName = rawTargetCountry.replacingOccurrences(of: " ", with: "_")
            let rawOptions = pickCountryDistractors(targetCountry: rawTargetCountry, level: level)
            let localizedTarget = localizedCountryName(for: rawTargetCountry)
            let localizedOptions = rawOptions.map { localizedCountryName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

            return Question(
                itemKey: itemKey,
                text: localizedTarget,
                subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime,
                flagImageName: flagAssetName
            )
        }
    }

    private func generateChemSymbolsQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let total = allElements.count
        guard total > 0 else { return [] }

        let indices: [Int]
        switch level {
        case .beginner: indices = Array(0..<min(25, total))
        case .easy: indices = Array(0..<min(50, total))
        case .medium: indices = Array(min(20, total - 1)..<min(70, total))
        case .hard: indices = Array(min(40, total - 1)..<min(95, total))
        case .ultimate: indices = Array(min(60, total - 1)..<min(105, total))
        case .godlike: indices = Array(min(70, total - 1)..<total)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in indices {
            let elem = allElements[idx]
            let key = "chem_\(elem.symbol)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = indices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        while selectedIndices.count < count {
            if let randIdx = indices.randomElement() {
                selectedIndices.append(randIdx)
            }
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let targetElem = allElements[idx]
            let itemKey = "chem_\(targetElem.symbol)"
            let rawOptions = pickChemSymbolDistractors(targetElem: targetElem, level: level)
            let localizedTarget = localizedElementName(for: targetElem.name)
            let localizedOptions = rawOptions.map { localizedElementName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

            return Question(
                itemKey: itemKey,
                text: targetElem.symbol,
                subtext: NSLocalizedString("prompt_chem_symbol", comment: "What element"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateChemNamesQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let total = allElements.count
        guard total > 0 else { return [] }

        let indices: [Int]
        switch level {
        case .beginner: indices = Array(0..<min(25, total))
        case .easy: indices = Array(0..<min(50, total))
        case .medium: indices = Array(min(20, total - 1)..<min(70, total))
        case .hard: indices = Array(min(40, total - 1)..<min(95, total))
        case .ultimate: indices = Array(min(60, total - 1)..<min(105, total))
        case .godlike: indices = Array(min(70, total - 1)..<total)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in indices {
            let elem = allElements[idx]
            let key = "chem_\(elem.symbol)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = indices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        while selectedIndices.count < count {
            if let randIdx = indices.randomElement() {
                selectedIndices.append(randIdx)
            }
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let targetElem = allElements[idx]
            let itemKey = "chem_\(targetElem.symbol)"
            let options = pickChemNameDistractors(targetElem: targetElem, level: level)
            let correctIdx = options.firstIndex(of: targetElem.symbol) ?? 0
            let localizedTargetName = localizedElementName(for: targetElem.name)

            return Question(
                itemKey: itemKey,
                text: localizedTargetName,
                subtext: NSLocalizedString("prompt_chem_name", comment: "What is symbol"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateGenericQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        var questions: [Question] = []
        var usedSignatures = Set<String>()

        var attempts = 0
        while questions.count < count && attempts < 500 {
            attempts += 1
            let q = generateQuestion(gameType: gameType, level: level, questionIndex: questions.count)

            let signature: String
            if let steps = q.memorySteps {
                signature = steps.joined(separator: "_")
            } else if let grid = q.memoryGridItems {
                let gridSig = grid.map { "\($0.shapeSymbol)_\($0.colorName)" }.joined(separator: ",")
                signature = "\(q.text)_\(gridSig)"
            } else {
                signature = q.text
            }

            if !usedSignatures.contains(signature) {
                usedSignatures.insert(signature)
                let itemKey = "math_\(gameType.rawValue)_\(signature)"
                let questionWithKey = Question(
                    itemKey: itemKey,
                    text: q.text,
                    subtext: q.subtext,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    maxTime: q.maxTime,
                    flagImageName: q.flagImageName,
                    memorySteps: q.memorySteps,
                    memoryGridItems: q.memoryGridItems,
                    memoryPreviewSeconds: q.memoryPreviewSeconds
                )
                questions.append(questionWithKey)
            }
        }

        // Fallback: If unique signatures produced fewer than count questions, fill up to count (15)
        while questions.count < count {
            let q = generateQuestion(gameType: gameType, level: level, questionIndex: questions.count)
            let itemKey = "math_\(gameType.rawValue)_\(questions.count)_\(q.text)"
            let questionWithKey = Question(
                itemKey: itemKey,
                text: q.text,
                subtext: q.subtext,
                options: q.options,
                correctIndex: q.correctIndex,
                maxTime: q.maxTime,
                flagImageName: q.flagImageName,
                memorySteps: q.memorySteps,
                memoryGridItems: q.memoryGridItems,
                memoryPreviewSeconds: q.memoryPreviewSeconds
            )
            questions.append(questionWithKey)
        }

        return questions
    }


    private func generateMathProgressQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let keys = itemKeysForLevel(gameType: gameType, level: level)
        guard !keys.isEmpty else {
            return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
        }

        var priority1: [String] = []
        var priority2: [String] = []

        for key in keys {
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(key)
            } else {
                priority1.append(key)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedKeys: [String] = []
        selectedKeys.append(contentsOf: priority1.prefix(count))
        if selectedKeys.count < count {
            let needed = count - selectedKeys.count
            selectedKeys.append(contentsOf: priority2.prefix(needed))
        }

        if selectedKeys.count < count {
            let remaining = keys.filter { !selectedKeys.contains($0) }.shuffled()
            selectedKeys.append(contentsOf: remaining.prefix(count - selectedKeys.count))
        }

        while selectedKeys.count < count {
            if let randKey = keys.randomElement() {
                selectedKeys.append(randKey)
            }
        }

        selectedKeys.shuffle()

        return selectedKeys.map { key in
            makeMathQuestionFromKey(key: key, gameType: gameType, maxTime: maxTime)
        }
    }

    private func makeMathQuestionFromKey(key: String, gameType: GameType, maxTime: Double) -> Question {
        let parts = key.split(separator: "_")
        guard parts.count >= 4, let a = Int(parts[2]), let b = Int(parts[3]) else {
            return generateQuestion(gameType: gameType, level: .easy)
        }

        let text: String
        let subtext: String
        let correct: Int

        switch gameType {
        case .addition:
            text = "\(a) + \(b)"
            subtext = NSLocalizedString("prompt_calc_sum", comment: "Calculate sum")
            correct = a + b
        case .subtraction:
            text = "\(a) - \(b)"
            subtext = NSLocalizedString("prompt_calc_diff", comment: "Calculate difference")
            correct = a - b
        case .multiplication:
            text = "\(a) × \(b)"
            subtext = NSLocalizedString("prompt_calc_product", comment: "Calculate product")
            correct = a * b
        case .division:
            text = "\(a) ÷ \(b)"
            subtext = NSLocalizedString("prompt_calc_quotient", comment: "Calculate quotient")
            correct = a / b
        default:
            text = "\(a) + \(b)"
            subtext = ""
            correct = a + b
        }

        let options = makeNumericOptions(correct: correct, range: 10)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(
            itemKey: key,
            text: text,
            subtext: subtext,
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }
}
