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
