import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case french = "fr"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .french: "Français"
        }
    }
}

struct PeloteClub: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let region: String
    let disciplines: [String]
    let homePlaces: [String]
    let founded: String
    let members: String
    let website: String
    let imageName: String
    let imageCredit: String
    let logoName: String?
    let logoCredit: String
    let bestFor: String
    let note: String
    let highlights: [String]
    let source: String
}

struct Venue: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let region: String
    let disciplines: [String]
    let surface: String
    let level: String
    let addressHint: String
    let website: String
    let founded: String
    let members: String
    let imageName: String
    let imageCredit: String
    let bestFor: String
    let note: String
    let highlights: [String]
    let source: String
}

struct Drill: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let focus: String
    let summary: String
    let minutes: Int
    let intensity: Int
    let equipment: String
    let diagram: String
    let target: String
    let steps: [String]
    let mistakes: [String]
}

struct RuleCard: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let summary: String
    let diagram: String
    let details: [String]
    let checkpoints: [String]
}

struct MatchRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let venueID: String
    let discipline: String
    let homeName: String
    let awayName: String
    let homeScore: Int
    let awayScore: Int
    let target: Int
    let rallyCount: Int
    let note: String

    var winnerName: String {
        homeScore == awayScore ? "Draw" : (homeScore > awayScore ? homeName : awayName)
    }

    var scoreline: String {
        "\(homeScore)-\(awayScore)"
    }
}

struct TrainingLog: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let drillID: String
    let minutes: Int
    let perceivedEffort: Int
    let note: String
}

struct OfficialMatchStat: Identifiable, Hashable {
    let id: String
    let competition: String
    let discipline: String
    let dateLabel: String
    let venue: String
    let result: String
    let note: String
    let source: String
}

struct MatchAnalytics {
    let played: Int
    let wins: Int
    let losses: Int
    let draws: Int
    let pointsFor: Int
    let pointsAgainst: Int
    let averageRallies: Double

    var winRate: Int {
        guard played > 0 else { return 0 }
        return Int((Double(wins) / Double(played) * 100).rounded())
    }

    var pointDifferential: Int {
        pointsFor - pointsAgainst
    }
}

final class LBTBasqueStore: ObservableObject {
    @Published var matches: [MatchRecord] {
        didSet { save(matches, key: Keys.matches) }
    }

    @Published var trainingLogs: [TrainingLog] {
        didSet { save(trainingLogs, key: Keys.trainingLogs) }
    }

    @Published var favoriteVenueIDs: Set<String> {
        didSet { save(Array(favoriteVenueIDs), key: Keys.favoriteVenues) }
    }

    @Published var favoriteClubIDs: Set<String> {
        didSet { save(Array(favoriteClubIDs), key: Keys.favoriteClubs) }
    }

    @Published var weeklyGoalMinutes: Int {
        didSet { UserDefaults.standard.set(weeklyGoalMinutes, forKey: Keys.weeklyGoalMinutes) }
    }

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    init() {
        matches = Self.load([MatchRecord].self, key: Keys.matches) ?? []
        trainingLogs = Self.load([TrainingLog].self, key: Keys.trainingLogs) ?? []
        favoriteVenueIDs = Set(Self.load([String].self, key: Keys.favoriteVenues) ?? [])
        favoriteClubIDs = Set(Self.load([String].self, key: Keys.favoriteClubs) ?? [])
        let savedGoal = UserDefaults.standard.integer(forKey: Keys.weeklyGoalMinutes)
        weeklyGoalMinutes = savedGoal == 0 ? 90 : savedGoal
        language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: Keys.language) ?? "") ?? .english
    }

    var totalTrainingMinutes: Int {
        trainingLogs.map(\.minutes).reduce(0, +)
    }

    var weekTrainingMinutes: Int {
        let calendar = Calendar.current
        return trainingLogs
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
            .map(\.minutes)
            .reduce(0, +)
    }

    var favoriteVenues: [Venue] {
        LBTBasqueData.venues.filter { favoriteVenueIDs.contains($0.id) }
    }

    var favoriteClubs: [PeloteClub] {
        LBTBasqueData.clubs.filter { favoriteClubIDs.contains($0.id) }
    }

    var matchAnalytics: MatchAnalytics {
        let played = matches.count
        let wins = matches.filter { $0.homeScore > $0.awayScore }.count
        let losses = matches.filter { $0.homeScore < $0.awayScore }.count
        let draws = matches.filter { $0.homeScore == $0.awayScore }.count
        let pointsFor = matches.map(\.homeScore).reduce(0, +)
        let pointsAgainst = matches.map(\.awayScore).reduce(0, +)
        let averageRallies = played == 0 ? 0 : Double(matches.map(\.rallyCount).reduce(0, +)) / Double(played)
        return MatchAnalytics(played: played, wins: wins, losses: losses, draws: draws, pointsFor: pointsFor, pointsAgainst: pointsAgainst, averageRallies: averageRallies)
    }

    func addMatch(_ match: MatchRecord) {
        matches.insert(match, at: 0)
    }

    func addTrainingLog(_ log: TrainingLog) {
        trainingLogs.insert(log, at: 0)
    }

    func toggleFavorite(_ venue: Venue) {
        if favoriteVenueIDs.contains(venue.id) {
            favoriteVenueIDs.remove(venue.id)
        } else {
            favoriteVenueIDs.insert(venue.id)
        }
    }

    func toggleFavoriteClub(_ club: PeloteClub) {
        if favoriteClubIDs.contains(club.id) {
            favoriteClubIDs.remove(club.id)
        } else {
            favoriteClubIDs.insert(club.id)
        }
    }

    func resetDemoData() {
        matches.removeAll()
        trainingLogs.removeAll()
        favoriteVenueIDs.removeAll()
        favoriteClubIDs.removeAll()
        weeklyGoalMinutes = 90
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private enum Keys {
        static let matches = "lbtbasque.matches.v2"
        static let trainingLogs = "lbtbasque.training.logs.v2"
        static let favoriteVenues = "lbtbasque.favorite.venues.v2"
        static let favoriteClubs = "lbtbasque.favorite.clubs.v1"
        static let weeklyGoalMinutes = "lbtbasque.weekly.goal.minutes.v2"
        static let language = "lbtbasque.language.v1"
    }
}

enum LBTBasqueData {
    static let clubs: [PeloteClub] = [
        PeloteClub(id: "aviron-bayonnais", name: "Aviron Bayonnais Pelote Basque", city: "Bayonne", region: "Pays Basque", disciplines: ["main nue", "pala", "xare", "joko garbi", "rebot"], homePlaces: ["Trinquet Louis Etcheto", "Fronton Jean Dauger", "Hauts de Sainte Croix"], founded: "1912", members: "about 200 licensed", website: "https://www.avironbayonnais.fr/pelote", imageName: "VenueTrinquetModerne", imageCredit: "Photo: Visit Bayonne / Tourinsoft", logoName: "LogoAviron", logoCredit: "Logo: Aviron Bayonnais / Wikimedia Commons", bestFor: "Historic Bayonne club pathway from youth school to competition", note: "Aviron is a real omnisports club section. Its courts are several separate places, not the club itself.", highlights: ["Created in 1912", "Around 200 licensed players", "Training from age 6-7", "Uses Trinquet Louis Etcheto, Hauts de Sainte Croix and Jean Dauger"], source: "Aviron Bayonnais"),
        PeloteClub(id: "snb-pelote", name: "Société Nautique de Bayonne Pelote", city: "Bayonne", region: "Pays Basque", disciplines: ["pala", "paleta cuir", "main nue"], homePlaces: ["Trinquet Saint-Andre"], founded: "Historic section", members: "from age 7", website: "https://www.snbayonne.fr/pelote/", imageName: "VenueSaintAndre", imageCredit: "Photo: Daniel Villafruela, Wikimedia Commons", logoName: "LogoSNB", logoCredit: "Logo: Société Nautique de Bayonne", bestFor: "Local Bayonne club sessions and pala gomme pleine", note: "SNB is the club/section; Trinquet Saint-André is its practice place.", highlights: ["Youth welcome from age 7", "Pala gomme pleine focus", "1v1, 2v2 and mixed tournaments", "Uses the historic Trinquet Saint-André"], source: "Société Nautique de Bayonne"),
        PeloteClub(id: "biarritz-ac", name: "Biarritz Athletic Club", city: "Biarritz", region: "Pays Basque", disciplines: ["cesta punta", "pala", "paleta", "main nue", "xare"], homePlaces: ["Jai Alai Aguilera"], founded: "1951", members: "club school", website: "https://cestabiarritz.fr/", imageName: "VenueBiarritzAC", imageCredit: "Photo: Cesta Punta Biarritz", logoName: "LogoBiarritzAC", logoCredit: "Logo: Cesta Punta Biarritz", bestFor: "Cesta punta club culture, events and initiations", note: "BAC is the club; the Jai Alai at Aguilera is the place where it plays and hosts events.", highlights: ["Club founded in 1951", "Cesta punta school from 1956", "Biarritz Masters and Golden Glove events", "Based around the Jai Alai at Aguilera"], source: "Cesta Biarritz"),
        PeloteClub(id: "kostakoak", name: "Kostakoak", city: "Bidart", region: "Pays Basque", disciplines: ["cesta punta", "grand chistera", "pala ancha"], homePlaces: ["Grand Fronton de Bidart"], founded: "Club association", members: "100+ licensed", website: "https://www.kostakoak.com/", imageName: "VenueKostakoakBidart", imageCredit: "Photo: Harrieta171, Wikimedia Commons", logoName: "LogoKostakoak", logoCredit: "Logo: Kostakoak Bidart", bestFor: "Grand chistera evenings and tourist-friendly initiations", note: "Kostakoak is the Bidart club; the fronton is its main public playing place.", highlights: ["More than 100 licensed players", "Three disciplines", "Summer games Tuesday and Friday", "Initiation sessions at the Grand Fronton"], source: "Kostakoak"),
        PeloteClub(id: "olharroa", name: "Olharroa", city: "Guethary", region: "Pays Basque", disciplines: ["grand chistera", "cesta punta", "paleta", "pala"], homePlaces: ["Fronton de Guethary", "Trinquet"], founded: "1922", members: "150 licensed", website: "https://olharroa.fr/", imageName: "VenueOlharroaGuethary", imageCredit: "Photo: Harrieta171, Wikimedia Commons", logoName: "LogoOlharroa", logoCredit: "Club identity reference: Olharroa / HelloAsso profile", bestFor: "Heritage club culture and youth formation", note: "Olharroa is the club; Guéthary fronton and trinquet are the places.", highlights: ["Founded in 1922", "150 licensed players", "Fronton built in 1868", "Youth school from age 6"], source: "Olharroa"),
        PeloteClub(id: "section-paloise", name: "Section Paloise Pelote Basque", city: "Pau", region: "Bearn", disciplines: ["cesta punta", "main nue", "paleta", "pala"], homePlaces: ["Complexe de Pelote de Pau"], founded: "Omnisports section", members: "8 active world champions", website: "https://www.section-paloise.com/", imageName: "VenueSectionPaloise", imageCredit: "Photo: Joan Cantegrel, Wikimedia Commons", logoName: "LogoSectionPaloise", logoCredit: "Logo: Section Paloise / Wikimedia Commons", bestFor: "Bearn competition pathway and event culture", note: "Section Paloise is the team/club structure; the Pau complex is the playing place.", highlights: ["8 active world champions reported by the club", "5 national titles in 2018", "7 French championship finals in 2018", "School, competition and event programs"], source: "Section Paloise"),
        PeloteClub(id: "hardoytarrak", name: "Hardoytarrak", city: "Anglet", region: "Pays Basque", disciplines: ["main nue", "xistera joko garbi", "xare", "rebot", "pasaka"], homePlaces: ["Sutar", "El Hogar", "Haitz Pean"], founded: "Anglet club", members: "youth and adult groups", website: "https://hardoytarrak.eu/", imageName: "VenueKostakoakBidart", imageCredit: "Photo: Harrieta171, Wikimedia Commons", logoName: "LogoHardoytarrak", logoCredit: "Logo: Hardoytarrak", bestFor: "Multi-place Anglet club with initiation and school activity", note: "Hardoytarrak is a club using several Anglet places depending on speciality.", highlights: ["Main nue, joko garbi, xare and rebot", "Initiations for children and adults", "Uses Sutar, El Hogar and Haitz Pean", "Club contact based in Anglet"], source: "Hardoytarrak")
    ]

    static let venues: [Venue] = [
        Venue(id: "trinquet-moderne", name: "Trinquet Moderne", city: "Bayonne", region: "Pays Basque", disciplines: ["main nue", "pala", "xare"], surface: "Glass-wall trinquet", level: "Initiation to championships", addressHint: "60 avenue Dubrocq, 64100 Bayonne", website: "https://trinquetmoderne.com/", founded: "FFPB seat", members: "1200 seats", imageName: "VenueTrinquetModerne", imageCredit: "Photo: Visit Bayonne / Tourinsoft", bestFor: "Structured initiation, rentals and high-level events", note: "A real Bayonne playing venue used for initiations, rentals and major competitions. Clubs may use it, but it is not itself a team.", highlights: ["FFPB headquarters in Bayonne", "Glass-wall trinquet", "Public rental slots via Giltza", "Championships, Masters and training sessions"], source: "Visit Bayonne / Trinquet Moderne"),
        Venue(id: "snb-saint-andre", name: "Trinquet Saint-Andre", city: "Bayonne", region: "Pays Basque", disciplines: ["pala", "paleta cuir", "main nue"], surface: "Historic trinquet", level: "Club sessions", addressHint: "18 rue du Trinquet, 64100 Bayonne", website: "https://www.snbayonne.fr/pelote/", founded: "Historic court", members: "indoor court", imageName: "VenueSaintAndre", imageCredit: "Photo: Daniel Villafruela, Wikimedia Commons", bestFor: "Classic Bayonne trinquet play and pala sessions", note: "The place used by SNB Pelote. The club is listed under Teams; this card is only the court.", highlights: ["Historic Bayonne trinquet", "Indoor wall play", "Used for pala and paleta formats", "Useful for controlled training sessions"], source: "Société Nautique de Bayonne / Visit Bayonne"),
        Venue(id: "biarritz-ac", name: "Jai Alai Aguilera", city: "Biarritz", region: "Pays Basque", disciplines: ["cesta punta", "pala", "paleta", "main nue", "xare"], surface: "Jai Alai + trinquet", level: "Initiation to pro events", addressHint: "Parc des Sports d'Aguilera, 64200 Biarritz", website: "https://cestabiarritz.fr/", founded: "1977 Jai Alai", members: "1800 seats", imageName: "VenueBiarritzAC", imageCredit: "Photo: Cesta Punta Biarritz", bestFor: "Cesta punta spectacle, initiations and competition nights", note: "The playing venue for Biarritz Athletic Club events. BAC is the team; Aguilera is the place.", highlights: ["Jai Alai at Aguilera", "Cesta punta events", "Short left wall and trinquet context", "Public match nights and initiations"], source: "Cesta Biarritz / Tourisme 64"),
        Venue(id: "kostakoak-bidart", name: "Grand Fronton de Bidart", city: "Bidart", region: "Pays Basque", disciplines: ["cesta punta", "grand chistera", "pala ancha"], surface: "Grand fronton", level: "Club and summer spectacle", addressHint: "Fronton de Bidart, 64210 Bidart", website: "https://www.kostakoak.com/", founded: "Public fronton", members: "open-air place", imageName: "VenueKostakoakBidart", imageCredit: "Photo: Harrieta171, Wikimedia Commons", bestFor: "Grand chistera evenings and open-air games", note: "The fronton used by Kostakoak. The team is listed separately under Teams.", highlights: ["Open-air fronton", "Summer games Tuesday and Friday", "Initiation sessions at the Grand Fronton", "Good for watching line calls and spacing"], source: "Kostakoak / Bidart Tourisme"),
        Venue(id: "olharroa-guethary", name: "Fronton de Guethary", city: "Guethary", region: "Pays Basque", disciplines: ["grand chistera", "cesta punta", "paleta", "pala"], surface: "Village fronton + trinquet nearby", level: "Heritage formats", addressHint: "288 avenue du General de Gaulle, 64210 Guethary", website: "https://olharroa.fr/", founded: "1868 fronton", members: "village place", imageName: "VenueOlharroaGuethary", imageCredit: "Photo: Harrieta171, Wikimedia Commons", bestFor: "Traditional village-fronton rhythm and heritage play", note: "The Guéthary playing place associated with Olharroa. The club itself is listed under Teams.", highlights: ["Fronton built in 1868", "Village pelota setting", "Used around Olharroa club culture", "Good place to understand heritage formats"], source: "Olharroa / Ville de Guethary"),
        Venue(id: "section-paloise", name: "Complexe de Pelote de Pau", city: "Pau", region: "Bearn", disciplines: ["cesta punta", "main nue", "paleta", "pala"], surface: "Pelota complex", level: "School to national finals", addressHint: "Complexe de pelote de Pau, 64000 Pau", website: "https://www.section-paloise.com/", founded: "Pau complex", members: "multi-court venue", imageName: "VenueSectionPaloise", imageCredit: "Photo: Joan Cantegrel, Wikimedia Commons", bestFor: "Bearn training, competition and event hosting", note: "The Pau playing complex. Section Paloise is the team/club structure listed under Teams.", highlights: ["Cesta punta and wall-game venue", "Used by Section Paloise programs", "Event and school context", "Strong Bearn competition base"], source: "Section Paloise")
    ]

    static let officialStats: [OfficialMatchStat] = [
        OfficialMatchStat(id: "proam-2024-p1a", competition: "Championnat de France Cesta Punta Pro-Am 2024", discipline: "cesta punta", dateLabel: "Playoff pool", venue: "FFPB pool 1", result: "Kostakoak - Bidart 02: 11 / 06", note: "Pool score listed by FFPB during the Pro-Am playoffs.", source: "FFPB"),
        OfficialMatchStat(id: "proam-2024-p1b", competition: "Championnat de France Cesta Punta Pro-Am 2024", discipline: "cesta punta", dateLabel: "Playoff pool", venue: "FFPB pool 1", result: "SA Mauleonais 01: 15 / 15", note: "A drawn pool score from the official playoff listing.", source: "FFPB"),
        OfficialMatchStat(id: "proam-2024-bac-section", competition: "Championnat de France Cesta Punta Pro-Am 2024", discipline: "cesta punta", dateLabel: "Playoff pool", venue: "FFPB pool 1", result: "Biarritz AC 01: 15 / 15; Section Paloise 01: 06 / 09", note: "Official FFPB page lists both teams and their pool scores.", source: "FFPB")
    ]

    static let drills: [Drill] = [
        Drill(id: "wall-lines", title: "Wall Lines", focus: "Accuracy", summary: "Build a repeatable height window on the front wall before adding pace.", minutes: 18, intensity: 2, equipment: "Tape, chalk or existing wall marks; ball; pala optional", diagram: "lanes", target: "30 clean contacts: 10 low, 10 middle, 10 high", steps: ["Mark low, middle and high target lanes on the front wall.", "Start three steps behind the service line and play controlled returns.", "Count only contacts that reach the lane and rebound back into the playable court.", "Restart the lane if your feet drift forward after contact."], mistakes: ["Swinging harder after a miss instead of resetting height.", "Watching the wall target too long and losing ready position.", "Letting the ball rebound too deep before moving."]),
        Drill(id: "serve-corridor", title: "Serve Corridor", focus: "Serve pressure", summary: "Use a narrow landing corridor to make first serves more deliberate.", minutes: 14, intensity: 3, equipment: "Court line, tape corridor or two cones", diagram: "corridor", target: "7 legal first bounces from 10 attempts", steps: ["Choose one legal service lane and mark a narrow landing corridor.", "Alternate a flat serve and a lifted serve so the body does not memorize one rhythm.", "Call the target before the serve, then record the first bounce only.", "Finish with five serves under match tempo."], mistakes: ["Changing the toss after every miss.", "Chasing power before the first bounce is reliable.", "Landing off balance and losing the next-ball position."]),
        Drill(id: "left-wall-read", title: "Left-Wall Read", focus: "Reaction", summary: "Train the first step after a side-wall rebound instead of guessing early.", minutes: 20, intensity: 4, equipment: "Partner feed; left-wall court or marked rebound zone", diagram: "rebound", target: "20 called rebounds with balanced contact", steps: ["Partner feeds cross-court balls toward the left wall or rebound zone.", "Call long, short or open before moving your second step.", "Recover to the center lane after every contact.", "End each set with five defensive lifts above the safe height line."], mistakes: ["Moving before reading the wall angle.", "Opening the shoulders too early on the backhand side.", "Finishing the point and forgetting recovery."]),
        Drill(id: "soft-hand-reset", title: "Soft Hand Reset", focus: "Control", summary: "Slow the game down with low-force touches and clean spacing.", minutes: 12, intensity: 1, equipment: "Soft ball or lower-compression practice ball", diagram: "touch", target: "Longest unbroken control streak", steps: ["Stand close enough to the wall that power is unnecessary.", "Play soft touches with a compact swing and quiet feet.", "Keep the rebound below shoulder height unless the court format requires more.", "Write down the longest streak and repeat once."], mistakes: ["Reaching with the arm instead of moving the feet.", "Letting the wrist collapse on contact.", "Treating a control drill like a scoring rally."]),
        Drill(id: "two-ball-choices", title: "Two-Ball Choices", focus: "Decision making", summary: "Practice late information: react only after the cue, then choose placement.", minutes: 16, intensity: 3, equipment: "Partner, two balls or two visible target calls", diagram: "choice", target: "12 balanced contacts from 16 late cues", steps: ["Partner shows or calls one of two balls late.", "Move only after the cue, then choose cross-court or straight placement.", "Score one point for balanced contact and one for correct placement.", "Swap roles after two short sets."], mistakes: ["Pre-loading toward the favorite side.", "Counting a rushed contact as a success.", "Forgetting to call the decision out loud."])
    ]

    static let rules: [RuleCard] = [
        RuleCard(id: "what", title: "What is pelote basque?", summary: "A French-Basque family of court games built around striking a ball toward a front wall.", diagram: "court", details: ["Formats vary by court: trinquet, fronton, mur a gauche and plaza.", "Players use bare hand, pala, chistera, cesta punta or xare depending on discipline.", "The shared idea is simple: send the ball to the playable wall and make the next return difficult but legal.", "L Basque separates teams from playing places so newcomers do not confuse clubs with courts."], checkpoints: ["Identify the court format first.", "Confirm the instrument and ball.", "Ask the local scoring target."]),
        RuleCard(id: "court", title: "Court formats", summary: "The playable walls and side limits change the rhythm more than the app name of the discipline.", diagram: "formats", details: ["A trinquet is enclosed and includes side-wall rebounds, making angles and control central.", "A fronton place libre is open-air, often with more visible spacing and local line habits.", "A mur a gauche uses a left wall, so reading the rebound angle is a major skill.", "Jai alai courts are longer and faster, especially in cesta punta."], checkpoints: ["Front wall line is the main reference.", "Side wall changes recovery position.", "Outdoor courts need extra agreement on boundaries."]),
        RuleCard(id: "rally", title: "Rally basics", summary: "The ball must reach the front wall and stay inside the playable lines after the rebound.", diagram: "rally", details: ["A side loses the rally after an out ball, a missed return, an illegal bounce or a ball that fails to reach the front wall.", "Many formats allow the ball to bounce once before the return; some local games or training formats may vary.", "After contact, recover toward the center lane instead of admiring the shot.", "When learning, focus first on safe height, then placement, then pace."], checkpoints: ["Front wall reached.", "Rebound stays playable.", "Receiver has safe space."]),
        RuleCard(id: "scoring", title: "Scoring", summary: "Club games often use target scores such as 25, 30, 35 or 40, with event-specific variations.", diagram: "score", details: ["Friendly games can use L Basque targets and saved notes for practical tracking.", "Formal competitions follow the sheet published by the organizer or federation.", "A saved rally count helps reveal whether a match was fast points, long exchanges or serve-dominant.", "Use notes to record serve pattern, court condition and the shot that won most points."], checkpoints: ["Set target before play.", "Record final score immediately.", "Save context, not only points."]),
        RuleCard(id: "etiquette", title: "Etiquette", summary: "Share walls, warm up gradually and announce unsafe balls early.", diagram: "safety", details: ["Do not cross another player's swing line during contact preparation.", "Call unsafe balls early, especially on shared walls and public frontons.", "Let beginners take controlled feeds before fast rally play.", "Outdoor frontons can be public spaces, so keep sessions tidy and compact."], checkpoints: ["Warm up the wall and arm.", "Keep swing lanes clear.", "Leave the court clean."]),
        RuleCard(id: "gear", title: "Gear and safety", summary: "Match the instrument and ball to the court, level and format.", diagram: "gear", details: ["Start with lower-compression balls during practice or initiation.", "Wear court shoes with lateral support and avoid slippery outdoor soles.", "Fast left-wall and cesta sessions deserve eye-safety discipline even in casual play.", "If the ball or instrument feels too fast for the group, lower the intensity instead of forcing the session."], checkpoints: ["Correct ball hardness.", "Stable shoes.", "Eyes protected in fast formats."])
    ]
}

extension Drill {
    func localized(_ language: AppLanguage) -> Drill {
        guard language == .french else { return self }

        switch id {
        case "wall-lines":
            return Drill(id: id, title: "Lignes du mur", focus: "Précision", summary: "Construire une fenêtre de hauteur régulière sur le frontis avant d'ajouter de la vitesse.", minutes: minutes, intensity: intensity, equipment: "Ruban, craie ou repères existants; balle; pala optionnelle", diagram: diagram, target: "30 contacts propres: 10 bas, 10 milieu, 10 haut", steps: ["Marquer trois zones cibles sur le frontis.", "Partir derrière la ligne de service et jouer des retours contrôlés.", "Compter seulement les balles qui touchent la zone et reviennent dans l'aire jouable.", "Recommencer la zone si les appuis avancent après l'impact."], mistakes: ["Frapper plus fort après une faute au lieu de retrouver la hauteur.", "Regarder la cible trop longtemps et perdre la position d'attente.", "Laisser le rebond devenir trop profond avant de bouger."])
        case "serve-corridor":
            return Drill(id: id, title: "Couloir de service", focus: "Pression au service", summary: "Utiliser un couloir étroit pour rendre le premier service plus intentionnel.", minutes: minutes, intensity: intensity, equipment: "Ligne du court, ruban ou deux cônes", diagram: diagram, target: "7 premiers rebonds valides sur 10 essais", steps: ["Choisir une zone de service légale et marquer un couloir.", "Alterner service tendu et service levé.", "Annoncer la cible avant le geste, puis noter uniquement le premier rebond.", "Finir par cinq services au rythme du match."], mistakes: ["Changer le lancer après chaque faute.", "Chercher la puissance avant la fiabilité du premier rebond.", "Finir déséquilibré et perdre la position de seconde balle."])
        case "left-wall-read":
            return Drill(id: id, title: "Lecture du mur gauche", focus: "Réaction", summary: "Entraîner le premier appui après un rebond latéral au lieu d'anticiper trop tôt.", minutes: minutes, intensity: intensity, equipment: "Relance partenaire; mur gauche ou zone de rebond marquée", diagram: diagram, target: "20 rebonds annoncés avec contact équilibré", steps: ["Le partenaire envoie des balles croisées vers le mur gauche.", "Annoncer long, court ou ouvert avant le deuxième appui.", "Revenir dans le couloir central après chaque contact.", "Terminer chaque série avec cinq défenses hautes."], mistakes: ["Partir avant de lire l'angle du mur.", "Ouvrir les épaules trop tôt côté revers.", "Oublier la récupération après le coup."])
        case "soft-hand-reset":
            return Drill(id: id, title: "Main douce", focus: "Contrôle", summary: "Ralentir le jeu avec des touches souples et un bon espacement.", minutes: minutes, intensity: intensity, equipment: "Balle souple ou balle d'initiation", diagram: diagram, target: "Plus longue série de contrôle sans rupture", steps: ["Se placer près du mur pour éviter la puissance inutile.", "Jouer des touches compactes avec des appuis calmes.", "Garder le rebond sous l'épaule sauf exigence locale.", "Noter la meilleure série et recommencer une fois."], mistakes: ["Tendre le bras au lieu de déplacer les pieds.", "Casser le poignet à l'impact.", "Transformer un exercice de contrôle en rallye de score."])
        case "two-ball-choices":
            return Drill(id: id, title: "Choix à deux balles", focus: "Décision", summary: "Travailler l'information tardive: réagir après le signal puis choisir le placement.", minutes: minutes, intensity: intensity, equipment: "Partenaire, deux balles ou deux appels de cible", diagram: diagram, target: "12 contacts équilibrés sur 16 signaux tardifs", steps: ["Le partenaire montre ou annonce tardivement l'une des deux options.", "Bouger seulement après le signal, puis choisir croisé ou direct.", "Marquer un point pour l'équilibre et un point pour le bon placement.", "Changer les rôles après deux séries courtes."], mistakes: ["Précharger vers le côté préféré.", "Compter un contact précipité comme réussite.", "Oublier d'annoncer la décision à voix haute."])
        default:
            return self
        }
    }
}

extension RuleCard {
    func localized(_ language: AppLanguage) -> RuleCard {
        guard language == .french else { return self }

        switch id {
        case "what":
            return RuleCard(id: id, title: "Qu'est-ce que la pelote basque?", summary: "Une famille franco-basque de jeux de court où la balle est envoyée vers un frontis.", diagram: diagram, details: ["Les formats varient selon le court: trinquet, fronton, mur à gauche et place libre.", "Les joueurs utilisent main nue, pala, chistera, cesta punta ou xare selon la spécialité.", "L'idée commune: envoyer la balle vers le mur jouable et rendre le retour suivant difficile mais légal.", "L Basque sépare les équipes des lieux de jeu pour éviter de confondre club et court."], checkpoints: ["Identifier le format du court.", "Confirmer l'instrument et la balle.", "Demander le score cible local."])
        case "court":
            return RuleCard(id: id, title: "Formats de court", summary: "Les murs jouables et les limites latérales changent le rythme plus que le nom de la spécialité.", diagram: diagram, details: ["Le trinquet est fermé et favorise les angles et le contrôle.", "La place libre est souvent en extérieur avec des repères locaux très visibles.", "Le mur à gauche impose une lecture rapide de l'angle de rebond.", "Le jai alai est plus long et plus rapide, surtout en cesta punta."], checkpoints: ["Le frontis est la référence principale.", "Le mur latéral change la récupération.", "En extérieur, valider les limites avant de jouer."])
        case "rally":
            return RuleCard(id: id, title: "Base du rallye", summary: "La balle doit atteindre le frontis et rester dans les lignes jouables après le rebond.", diagram: diagram, details: ["Un camp perd l'échange après une balle dehors, un retour manqué, un rebond illégal ou une balle qui n'atteint pas le frontis.", "Beaucoup de formats autorisent un rebond avant le retour; les habitudes locales peuvent varier.", "Après le contact, revenir vers le couloir central.", "Pour apprendre, viser d'abord la hauteur sûre, puis le placement, puis la vitesse."], checkpoints: ["Frontis atteint.", "Rebond jouable.", "Espace sûr pour le receveur."])
        case "scoring":
            return RuleCard(id: id, title: "Score", summary: "Les parties de club utilisent souvent 25, 30, 35 ou 40 points selon le format.", diagram: diagram, details: ["Les parties amicales peuvent utiliser les cibles L Basque et les notes sauvegardées.", "Les compétitions officielles suivent la feuille publiée par l'organisateur ou la fédération.", "Le nombre d'échanges montre si le match était rapide, long ou dominé par le service.", "Noter le service, l'état du court et le coup qui a gagné le plus de points."], checkpoints: ["Fixer la cible avant la partie.", "Enregistrer le score final immédiatement.", "Sauvegarder le contexte, pas seulement les points."])
        case "etiquette":
            return RuleCard(id: id, title: "Étiquette", summary: "Partager les murs, s'échauffer progressivement et annoncer les balles dangereuses tôt.", diagram: diagram, details: ["Ne pas traverser la ligne de geste d'un autre joueur.", "Annoncer tôt les balles dangereuses, surtout sur les frontons publics.", "Laisser les débutants recevoir des balles contrôlées avant le jeu rapide.", "Sur une place libre, garder la séance propre et compacte."], checkpoints: ["Échauffer bras et mur.", "Garder les couloirs de geste libres.", "Laisser le court propre."])
        case "gear":
            return RuleCard(id: id, title: "Matériel et sécurité", summary: "Adapter instrument et balle au court, au niveau et à la spécialité.", diagram: diagram, details: ["Commencer avec des balles moins dures en initiation.", "Porter des chaussures stables en appuis latéraux.", "Les séances rapides au mur gauche et en cesta méritent une vraie discipline de protection des yeux.", "Si la balle ou l'instrument est trop rapide, baisser l'intensité."], checkpoints: ["Bonne dureté de balle.", "Chaussures stables.", "Yeux protégés en format rapide."])
        default:
            return self
        }
    }
}

enum L10n {
    static func text(_ key: String, _ language: AppLanguage) -> String {
        guard language == .french else { return english[key] ?? key }
        return french[key] ?? english[key] ?? key
    }

    private static let english: [String: String] = [
        "home": "Home", "score": "Score", "clubs": "Clubs", "train": "Train", "rules": "Rules",
        "teamsPlaces": "Teams & Places", "language": "Language", "releaseReady": "Release readiness",
        "releaseAudit": "Content is split between real teams and real places, match stats are saved locally, images have credits, and training/rules now include practical guidance.",
        "savedMatches": "saved matches", "minutesThisWeek": "minutes this week", "favoriteTeams": "favorite teams", "placesToPlay": "places to play",
        "brandSubtitle": "Pelote Basque France", "brandCopy": "Plan a court session, score a match, save results, track training and learn the rules of France's Basque-wall sport.",
        "weeklyTraining": "Weekly training", "goal": "Goal", "matchStatistics": "Match statistics", "officialSnapshot": "Official snapshot",
        "recentMatches": "Recent matches", "pinned": "Pinned teams & places", "searchRules": "Search rules", "searchDirectory": "City, court, discipline",
        "drillPicker": "Choose exercise", "drillTimer": "Drill timer", "howToDo": "How to do it", "avoid": "Avoid", "trainingNote": "Training note",
        "logTraining": "Log Training Session", "trainingHistory": "Training history", "noTraining": "No training logged", "runDrill": "Run a drill and save the session.",
        "equipment": "Equipment", "target": "Target", "intensity": "Intensity", "start": "Start", "pause": "Pause", "reset": "Reset",
        "guide": "Pelote Guide", "knowCourt": "Know the court before you play.", "fastReference": "Fast reference for formats, rally calls, scoring and etiquette.",
        "keyChecks": "Key checks", "teams": "Teams", "places": "Places",
        "noMatchData": "No match data yet", "scoreSaveUnlock": "Score and save a match to unlock win rate, points and rally pace.",
        "noSavedMatches": "No saved matches yet", "finishSaveReal": "Use Score to finish and save a real match.",
        "nothingPinned": "Nothing pinned yet", "markTeamsPlaces": "Mark teams and places in Clubs to build a practical shortlist.",
        "team": "team", "place": "place", "matchSetup": "Match setup", "homeTeam": "Home", "awayTeam": "Away",
        "placePicker": "Place", "discipline": "Discipline", "targetScore": "Target", "undo": "Undo",
        "matchNote": "Match note: serve pattern, court condition, opponent style", "finishSave": "Finish and Save Match",
        "matchSaved": "Match saved", "matchSavedMessage": "The result is now in Home and match history.",
        "rallyLog": "Rally log", "noRallies": "No rallies yet", "addPointsLog": "Add points to build a point-by-point log.",
        "point": "Point", "homePoint": "Home point", "awayPoint": "Away point", "levelRally": "Level rally",
        "liveAfterSave": "Live after save", "matches": "matches", "homeWinRate": "home win rate", "pointDiff": "point diff",
        "points": "points", "avgRallies": "avg rallies"
    ]

    private static let french: [String: String] = [
        "home": "Accueil", "score": "Score", "clubs": "Clubs", "train": "Entraînement", "rules": "Règles",
        "teamsPlaces": "Équipes & lieux", "language": "Langue", "releaseReady": "Prêt pour sortie",
        "releaseAudit": "Le contenu distingue les vraies équipes des vrais lieux, les statistiques de match sont sauvegardées localement, les images sont créditées, et les entraînements/règles incluent désormais des consignes pratiques.",
        "savedMatches": "matchs sauvegardés", "minutesThisWeek": "minutes cette semaine", "favoriteTeams": "équipes favorites", "placesToPlay": "lieux pour jouer",
        "brandSubtitle": "Pelote basque France", "brandCopy": "Planifier une séance, scorer un match, sauvegarder les résultats, suivre l'entraînement et apprendre les règles de la pelote en France.",
        "weeklyTraining": "Entraînement hebdo", "goal": "Objectif", "matchStatistics": "Statistiques de match", "officialSnapshot": "Repère officiel",
        "recentMatches": "Matchs récents", "pinned": "Équipes & lieux épinglés", "searchRules": "Rechercher une règle", "searchDirectory": "Ville, court, discipline",
        "drillPicker": "Choisir un exercice", "drillTimer": "Chrono d'exercice", "howToDo": "Comment faire", "avoid": "À éviter", "trainingNote": "Note d'entraînement",
        "logTraining": "Enregistrer la séance", "trainingHistory": "Historique d'entraînement", "noTraining": "Aucun entraînement", "runDrill": "Lance un exercice puis sauvegarde la séance.",
        "equipment": "Matériel", "target": "Objectif", "intensity": "Intensité", "start": "Démarrer", "pause": "Pause", "reset": "Réinitialiser",
        "guide": "Guide pelote", "knowCourt": "Comprendre le court avant de jouer.", "fastReference": "Référence rapide pour formats, échanges, score et étiquette.",
        "keyChecks": "Points clés", "teams": "Équipes", "places": "Lieux",
        "noMatchData": "Aucune donnée de match", "scoreSaveUnlock": "Score et sauvegarde un match pour débloquer taux de victoire, points et rythme des échanges.",
        "noSavedMatches": "Aucun match sauvegardé", "finishSaveReal": "Utilise Score pour terminer et sauvegarder un vrai match.",
        "nothingPinned": "Rien d'épinglé", "markTeamsPlaces": "Marque des équipes et des lieux dans Clubs pour construire une sélection pratique.",
        "team": "équipe", "place": "lieu", "matchSetup": "Configuration du match", "homeTeam": "Domicile", "awayTeam": "Visiteurs",
        "placePicker": "Lieu", "discipline": "Discipline", "targetScore": "Cible", "undo": "Annuler",
        "matchNote": "Note de match: service, état du court, style adverse", "finishSave": "Terminer et sauvegarder",
        "matchSaved": "Match sauvegardé", "matchSavedMessage": "Le résultat est dans Accueil et l'historique.",
        "rallyLog": "Journal des échanges", "noRallies": "Aucun échange", "addPointsLog": "Ajoute des points pour créer un journal échange par échange.",
        "point": "Point", "homePoint": "Point domicile", "awayPoint": "Point visiteurs", "levelRally": "Échange à égalité",
        "liveAfterSave": "Actif après sauvegarde", "matches": "matchs", "homeWinRate": "victoires domicile", "pointDiff": "diff. points",
        "points": "points", "avgRallies": "moy. échanges"
    ]
}

extension Color {
    static let lbtBasqueGreen = Color(red: 0.0, green: 0.43, blue: 0.18)
    static let lbtBasqueDeepGreen = Color(red: 0.015, green: 0.15, blue: 0.07)
    static let lbtBasqueField = Color(red: 0.018, green: 0.20, blue: 0.095)
    static let lbtBasqueFieldTop = Color(red: 0.035, green: 0.29, blue: 0.13)
    static let lbtBasqueBlack = Color(red: 0.035, green: 0.045, blue: 0.038)
    static let lbtBasqueIvory = Color(red: 0.965, green: 0.965, blue: 0.925)
    static let lbtBasquePaper = Color(red: 0.985, green: 0.982, blue: 0.955)
    static let lbtBasqueMuted = Color(red: 0.40, green: 0.45, blue: 0.39)
    static let lbtBasqueGold = Color(red: 0.76, green: 0.62, blue: 0.28)
}
