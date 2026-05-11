import SwiftUI

struct LBTBasqueContentView: View {
    @StateObject private var store = LBTBasqueStore()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label(L10n.text("home", store.language), systemImage: "sportscourt") }
            ScorerView()
                .tabItem { Label(L10n.text("score", store.language), systemImage: "number.square.fill") }
            DirectoryView()
                .tabItem { Label(L10n.text("clubs", store.language), systemImage: "person.3") }
            TrainingView()
                .tabItem { Label(L10n.text("train", store.language), systemImage: "timer") }
            RulesView()
                .tabItem { Label(L10n.text("rules", store.language), systemImage: "book.closed") }
        }
        .environmentObject(store)
        .tint(.lbtBasqueGreen)
        .dynamicTypeSize(.medium ... .large)
        .preferredColorScheme(.light)
        .toolbarBackground(Color.lbtBasqueIvory, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private struct DashboardView: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    BrandHeader()
                    LanguageSettingsCard()
                    NextActionCard()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(value: "\(store.matches.count)", label: L10n.text("savedMatches", store.language), icon: "list.number")
                        MetricCard(value: "\(store.weekTrainingMinutes)", label: L10n.text("minutesThisWeek", store.language), icon: "timer")
                        MetricCard(value: "\(store.favoriteClubIDs.count)", label: L10n.text("favoriteTeams", store.language), icon: "star.fill")
                        MetricCard(value: "\(LBTBasqueData.venues.count)", label: L10n.text("placesToPlay", store.language), icon: "mappin.and.ellipse")
                    }

                    MatchAnalyticsCard()
                    WeekProgressCard()
                    ReleaseReadinessCard()
                    OfficialStatsCard()
                    RecentMatchesCard()
                    FavoriteClubsAndPlacesCard()
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .lbtBasqueScreen()
            .navigationTitle("LBT Basque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct BrandHeader: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                LBTBasqueLogo(size: 82)
                VStack(alignment: .leading, spacing: 6) {
                    Text("LBT BASQUE")
                        .font(.system(size: 38, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.48)
                    Rectangle()
                        .fill(Color.lbtBasqueGreen)
                        .frame(height: 4)
                        .rotationEffect(.degrees(-2))
                    Text(L10n.text("brandSubtitle", store.language))
                        .font(.headline)
                        .foregroundStyle(Color.lbtBasqueMuted)
                }
            }
            Text(L10n.text("brandCopy", store.language))
                .font(.callout)
                .foregroundStyle(Color.lbtBasqueBlack.opacity(0.78))
        }
        .lbtBasqueCard()
    }
}

private struct LanguageSettingsCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(L10n.text("language", store.language), systemImage: "globe.europe.africa.fill")
                    .font(.headline)
                Spacer()
                Text(store.language.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.lbtBasqueGreen)
            }

            Picker(L10n.text("language", store.language), selection: $store.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .pickerStyle(.segmented)
        }
        .lbtBasqueCard()
    }
}

private struct NextActionCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    private var action: (title: String, text: String, icon: String) {
        if store.favoriteClubIDs.isEmpty && store.favoriteVenueIDs.isEmpty {
            return ("Build your pelote base", "Pin a team and a place so LBT Basque separates who you follow from where you play.", "star")
        }

        if store.matches.isEmpty {
            return ("Score the first match", "Use Score at your pinned court, save the result and start building match memory.", "number.square")
        }

        if store.weekTrainingMinutes < store.weeklyGoalMinutes {
            return ("Close the training gap", "\(store.weeklyGoalMinutes - store.weekTrainingMinutes) minutes left this week. Run a short control drill.", "timer")
        }

        return ("Review match patterns", "Your week is on track. Check recent results and write down one winning pattern.", "chart.line.uptrend.xyaxis")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: action.icon)
                .font(.title2.weight(.bold))
                .frame(width: 42, height: 42)
                .background(.white)
                .foregroundStyle(Color.lbtBasqueGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(action.title)
                    .font(.headline)
                Text(action.text)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.lbtBasqueBlack, Color.lbtBasqueDeepGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct WeekProgressCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var progress: Double {
        min(Double(store.weekTrainingMinutes) / Double(max(store.weeklyGoalMinutes, 1)), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(L10n.text("weeklyTraining", store.language), systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                Spacer()
                Text("\(store.weekTrainingMinutes)/\(store.weeklyGoalMinutes) min")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.lbtBasqueGreen)
            }
            ProgressView(value: progress)
                .tint(.lbtBasqueGreen)
            Stepper("\(L10n.text("goal", store.language)) \(store.weeklyGoalMinutes) min", value: $store.weeklyGoalMinutes, in: 30...300, step: 15)
                .font(.subheadline)
        }
        .lbtBasqueCard()
    }
}

private struct ReleaseReadinessCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(L10n.text("releaseReady", store.language), systemImage: "checkmark.seal.fill")
                    .font(.headline)
                Spacer()
                Text("iOS")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.lbtBasqueGold)
            }
            Text(L10n.text("releaseAudit", store.language))
                .font(.callout)
                .foregroundStyle(Color.lbtBasqueBlack.opacity(0.76))
        }
        .lbtBasqueCard()
    }
}

private struct MatchAnalyticsCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    private var stats: MatchAnalytics {
        store.matchAnalytics
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(L10n.text("matchStatistics", store.language))
                Spacer()
                Text(stats.played == 0 ? L10n.text("liveAfterSave", store.language) : "\(stats.played) \(L10n.text("matches", store.language))")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.lbtBasqueGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.lbtBasqueGreen.opacity(0.12))
                    .clipShape(Capsule())
            }

            if stats.played == 0 {
                EmptyStateRow(icon: "chart.xyaxis.line", title: L10n.text("noMatchData", store.language), text: L10n.text("scoreSaveUnlock", store.language))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MiniStat(value: "\(stats.winRate)%", label: L10n.text("homeWinRate", store.language))
                    MiniStat(value: "\(stats.pointDifferential)", label: L10n.text("pointDiff", store.language))
                    MiniStat(value: "\(stats.pointsFor)-\(stats.pointsAgainst)", label: L10n.text("points", store.language))
                    MiniStat(value: String(format: "%.1f", stats.averageRallies), label: L10n.text("avgRallies", store.language))
                }
                Text("\(stats.wins) wins, \(stats.losses) losses, \(stats.draws) draws from your saved LBT Basque matches.")
                    .font(.caption)
                    .foregroundStyle(Color.lbtBasqueMuted)
            }
        }
        .lbtBasqueCard()
    }
}

private struct OfficialStatsCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(L10n.text("officialSnapshot", store.language))
                Spacer()
                Text("FFPB")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.lbtBasqueGold)
            }
            Text("Cesta Punta Pro-Am playoff data gives the app a real competition reference while personal stats stay based on saved matches.")
                .font(.caption)
                .foregroundStyle(Color.lbtBasqueMuted)

            ForEach(LBTBasqueData.officialStats.prefix(2)) { stat in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(Color.lbtBasqueGold)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(stat.result)
                            .font(.subheadline.weight(.bold))
                        Text("\(stat.discipline) - \(stat.dateLabel)")
                            .font(.caption)
                            .foregroundStyle(Color.lbtBasqueMuted)
                    }
                    Spacer()
                }
                if stat.id != LBTBasqueData.officialStats.prefix(2).last?.id {
                    Divider()
                }
            }
        }
        .lbtBasqueCard()
    }
}

private struct RecentMatchesCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(L10n.text("recentMatches", store.language))
            if store.matches.isEmpty {
                EmptyStateRow(icon: "number.square", title: L10n.text("noSavedMatches", store.language), text: L10n.text("finishSaveReal", store.language))
            } else {
                ForEach(store.matches.prefix(3)) { match in
                    MatchRow(match: match)
                    if match.id != store.matches.prefix(3).last?.id {
                        Divider()
                    }
                }
            }
        }
        .lbtBasqueCard()
    }
}

private struct FavoriteClubsAndPlacesCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(L10n.text("pinned", store.language))
            if store.favoriteClubs.isEmpty && store.favoriteVenues.isEmpty {
                EmptyStateRow(icon: "star", title: L10n.text("nothingPinned", store.language), text: L10n.text("markTeamsPlaces", store.language))
            } else {
                ForEach(store.favoriteClubs.prefix(2)) { club in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(club.name)
                                .font(.headline)
                            Text("\(club.city) - \(L10n.text("team", store.language))")
                                .font(.caption)
                                .foregroundStyle(Color.lbtBasqueMuted)
                        }
                        Spacer()
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(Color.lbtBasqueGreen)
                    }
                }
                ForEach(store.favoriteVenues.prefix(2)) { venue in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(venue.name)
                                .font(.headline)
                            Text("\(venue.city) - \(L10n.text("place", store.language))")
                                .font(.caption)
                                .foregroundStyle(Color.lbtBasqueMuted)
                        }
                        Spacer()
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color.lbtBasqueGreen)
                    }
                }
            }
        }
        .lbtBasqueCard()
    }
}

private struct ScorerView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    @State private var homeName = "Bayonne"
    @State private var awayName = "Visitors"
    @State private var venueID = LBTBasqueData.venues[0].id
    @State private var discipline = "pala"
    @State private var target = 30
    @State private var note = ""
    @State private var homeScore = 0
    @State private var awayScore = 0
    @State private var events: [PointEvent] = []
    @State private var showingSaved = false

    private var leaderText: String {
        if homeScore == awayScore { return L10n.text("levelRally", store.language) }
        return homeScore > awayScore ? "\(homeName) leads" : "\(awayName) leads"
    }

    private var isFinishable: Bool {
        homeScore > 0 || awayScore > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    MatchSetupCard(homeName: $homeName, awayName: $awayName, venueID: $venueID, discipline: $discipline, target: $target)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(leaderText)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(homeScore)")
                            Text("-")
                            Text("\(awayScore)")
                        }
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        ProgressView(value: Double(max(homeScore, awayScore)), total: Double(target))
                            .tint(.white)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.lbtBasqueBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    HStack(spacing: 12) {
                        ScorePanel(name: homeName, score: homeScore, target: target) { addPoint(home: true) }
                        ScorePanel(name: awayName, score: awayScore, target: target) { addPoint(home: false) }
                    }

                    HStack(spacing: 10) {
                        Button { undo() } label: {
                            Label(L10n.text("undo", store.language), systemImage: "arrow.uturn.backward")
                        }
                        .buttonStyle(LBTBasqueSecondaryButton())
                        .disabled(events.isEmpty)

                        Button { resetMatch() } label: {
                            Label(L10n.text("reset", store.language), systemImage: "clock.arrow.circlepath")
                        }
                        .buttonStyle(LBTBasqueSecondaryButton())
                    }

                    TextField(L10n.text("matchNote", store.language), text: $note, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)

                    Button { saveMatch() } label: {
                        Label(L10n.text("finishSave", store.language), systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LBTBasquePrimaryButton())
                    .disabled(!isFinishable)

                    RallyHistoryCard(events: events)
                }
                .padding(16)
                .padding(.bottom, 28)
            }
            .lbtBasqueScreen()
            .navigationTitle(L10n.text("score", store.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert(L10n.text("matchSaved", store.language), isPresented: $showingSaved) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(L10n.text("matchSavedMessage", store.language))
            }
        }
    }

    private func addPoint(home: Bool) {
        if home {
            homeScore += 1
        } else {
            awayScore += 1
        }

        events.append(PointEvent(home: home, scoreline: "\(homeScore)-\(awayScore)", date: Date()))
    }

    private func undo() {
        guard let last = events.popLast() else { return }
        if last.home {
            homeScore = max(0, homeScore - 1)
        } else {
            awayScore = max(0, awayScore - 1)
        }
    }

    private func resetMatch() {
        homeScore = 0
        awayScore = 0
        events.removeAll()
        note = ""
    }

    private func saveMatch() {
        let match = MatchRecord(
            id: UUID(),
            date: Date(),
            venueID: venueID,
            discipline: discipline,
            homeName: homeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Home" : homeName,
            awayName: awayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Visitors" : awayName,
            homeScore: homeScore,
            awayScore: awayScore,
            target: target,
            rallyCount: events.count,
            note: note
        )
        store.addMatch(match)
        resetMatch()
        showingSaved = true
    }
}

private struct MatchSetupCard: View {
    @EnvironmentObject private var store: LBTBasqueStore
    @Binding var homeName: String
    @Binding var awayName: String
    @Binding var venueID: String
    @Binding var discipline: String
    @Binding var target: Int

    var disciplines: [String] {
        Array(Set(LBTBasqueData.venues.flatMap(\.disciplines))).sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(L10n.text("matchSetup", store.language))
            HStack(spacing: 10) {
                TextField(L10n.text("homeTeam", store.language), text: $homeName)
                    .textFieldStyle(.roundedBorder)
                TextField(L10n.text("awayTeam", store.language), text: $awayName)
                    .textFieldStyle(.roundedBorder)
            }
            Picker(L10n.text("placePicker", store.language), selection: $venueID) {
                ForEach(LBTBasqueData.venues) { venue in
                    Text("\(venue.city) - \(venue.name)").tag(venue.id)
                }
            }
            Picker(L10n.text("discipline", store.language), selection: $discipline) {
                ForEach(disciplines, id: \.self) { Text($0).tag($0) }
            }
            Picker(L10n.text("targetScore", store.language), selection: $target) {
                Text("25").tag(25)
                Text("30").tag(30)
                Text("35").tag(35)
                Text("40").tag(40)
            }
            .pickerStyle(.segmented)
        }
        .lbtBasqueCard()
    }
}

private struct ScorePanel: View {
    @EnvironmentObject private var store: LBTBasqueStore
    let name: String
    let score: Int
    let target: Int
    let addPoint: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(name.isEmpty ? "Team" : name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(height: 24)
            Text("\(score)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(score >= target ? Color.lbtBasqueGreen : Color.lbtBasqueBlack)
                .frame(height: 74)
            ProgressView(value: Double(min(score, target)), total: Double(target))
                .tint(.lbtBasqueGreen)
            Button(action: addPoint) {
                Label(L10n.text("point", store.language), systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LBTBasquePrimaryButton())
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct RallyHistoryCard: View {
    @EnvironmentObject private var store: LBTBasqueStore
    let events: [PointEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(L10n.text("rallyLog", store.language))
            if events.isEmpty {
                EmptyStateRow(icon: "plus.circle", title: L10n.text("noRallies", store.language), text: L10n.text("addPointsLog", store.language))
            } else {
                ForEach(events.reversed().prefix(8)) { event in
                    HStack {
                        Label(event.home ? L10n.text("homePoint", store.language) : L10n.text("awayPoint", store.language), systemImage: event.home ? "h.square" : "a.square")
                        Spacer()
                        Text(event.scoreline)
                            .font(.headline.monospacedDigit())
                    }
                    .font(.subheadline)
                }
            }
        }
        .lbtBasqueCard()
    }
}

private struct PointEvent: Identifiable, Hashable {
    let id = UUID()
    let home: Bool
    let scoreline: String
    let date: Date
}

private enum DirectoryMode: String, CaseIterable, Identifiable {
    case teams = "Teams"
    case places = "Places"

    var id: String { rawValue }
}

private struct DirectoryView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    @State private var mode: DirectoryMode = .teams
    @State private var selectedDiscipline = "All"
    @State private var searchText = ""

    private var disciplines: [String] {
        let values = mode == .teams ? LBTBasqueData.clubs.flatMap(\.disciplines) : LBTBasqueData.venues.flatMap(\.disciplines)
        return ["All"] + Array(Set(values)).sorted()
    }

    private var filteredClubs: [PeloteClub] {
        LBTBasqueData.clubs.filter { club in
            let matchesDiscipline = selectedDiscipline == "All" || club.disciplines.contains(selectedDiscipline)
            let searchable = [club.name, club.city, club.region, club.bestFor, club.source, club.homePlaces.joined(separator: " "), club.highlights.joined(separator: " ")].joined(separator: " ")
            let matchesSearch = searchText.isEmpty || searchable.localizedCaseInsensitiveContains(searchText)
            return matchesDiscipline && matchesSearch
        }
    }

    private var filteredVenues: [Venue] {
        LBTBasqueData.venues.filter { venue in
            let matchesDiscipline = selectedDiscipline == "All" || venue.disciplines.contains(selectedDiscipline)
            let searchable = [venue.name, venue.city, venue.region, venue.bestFor, venue.source, venue.highlights.joined(separator: " ")].joined(separator: " ")
            let matchesSearch = searchText.isEmpty || searchable.localizedCaseInsensitiveContains(searchText)
            return matchesDiscipline && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Picker("Directory type", selection: $mode) {
                        ForEach(DirectoryMode.allCases) { item in
                            Text(item == .teams ? L10n.text("teams", store.language) : L10n.text("places", store.language)).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) {
                        selectedDiscipline = "All"
                    }

                    PremiumSearchField(text: $searchText, prompt: L10n.text("searchDirectory", store.language))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(disciplines, id: \.self) { discipline in
                                FilterChip(title: discipline, isSelected: selectedDiscipline == discipline) {
                                    selectedDiscipline = discipline
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    if mode == .teams {
                        ForEach(filteredClubs) { club in
                            NavigationLink {
                                ClubDetailView(club: club)
                            } label: {
                                ClubPremiumCard(club: club, isFavorite: store.favoriteClubIDs.contains(club.id))
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ForEach(filteredVenues) { venue in
                            NavigationLink {
                                VenueDetailView(venue: venue)
                            } label: {
                                VenuePremiumCard(venue: venue, isFavorite: store.favoriteVenueIDs.contains(venue.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .lbtBasqueScreen()
            .navigationTitle(L10n.text("teamsPlaces", store.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct ClubPremiumCard: View {
    let club: PeloteClub
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                TeamLogoBadge(club: club, size: 72)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(club.name)
                            .font(.headline)
                            .foregroundStyle(Color.lbtBasqueBlack)
                        Spacer()
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? Color.lbtBasqueGold : Color.lbtBasqueMuted.opacity(0.65))
                    }
                    Text("\(club.city), \(club.region)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.lbtBasqueGreen)
                    Text(club.bestFor)
                        .font(.callout)
                        .foregroundStyle(Color.lbtBasqueBlack.opacity(0.72))
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                MiniStat(value: club.founded, label: "founded")
                MiniStat(value: club.members, label: "members")
            }

            FlowTags(tags: club.disciplines)
            SourceBadge(text: club.source)
        }
        .padding(14)
        .background(
            LinearGradient(colors: [Color.lbtBasquePaper, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

private struct ClubDetailView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    let club: PeloteClub

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                TeamIdentityHeader(club: club)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(club.name)
                            .font(.title2.weight(.black))
                        Spacer()
                        Button {
                            store.toggleFavoriteClub(club)
                        } label: {
                            Image(systemName: store.favoriteClubIDs.contains(club.id) ? "star.fill" : "star")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.lbtBasqueGreen)
                    }
                    Text("\(club.city), \(club.region)")
                        .foregroundStyle(Color.lbtBasqueMuted)
                    FlowTags(tags: club.disciplines)
                    SourceBadge(text: club.source)
                }
                .lbtBasqueCard()

                InfoBlock(title: "Team profile", icon: "person.3", text: club.bestFor)
                InfoBlock(title: "Home places", icon: "mappin.and.ellipse", text: club.homePlaces.joined(separator: ", "))
                InfoBlock(title: "Club note", icon: "note.text", text: club.note)
                InfoListBlock(title: "Real team notes", icon: "checklist", items: club.highlights)
                InfoBlock(title: "Logo credit", icon: "seal", text: club.logoCredit)
                InfoBlock(title: "Image credit", icon: "camera", text: club.imageCredit)
                Link(destination: URL(string: club.website)!) {
                    Label("Open official page", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(LBTBasquePrimaryButton())
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .lbtBasqueScreen()
        .navigationTitle(club.city)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct TeamIdentityHeader: View {
    let club: PeloteClub

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            TeamLogoBadge(club: club, size: 92)
            VStack(alignment: .leading, spacing: 8) {
                Text("Team")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.lbtBasqueGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.lbtBasqueGold.opacity(0.16))
                    .clipShape(Capsule())
                Text(club.name)
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(club.city), \(club.region)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.lbtBasqueBlack, Color.lbtBasqueDeepGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.34), lineWidth: 1)
        )
    }
}

private struct TeamLogoBadge: View {
    let club: PeloteClub
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white)
            if let logoName = club.logoName {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .padding(9)
            } else {
                VStack(spacing: 2) {
                    Text(String(club.name.prefix(1)))
                        .font(.system(size: size * 0.44, weight: .black, design: .rounded))
                    Text("TEAM")
                        .font(.system(size: size * 0.12, weight: .black))
                }
                .foregroundStyle(Color.lbtBasqueGreen)
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.32), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
    }
}

private struct VenuePremiumCard: View {
    let venue: Venue
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VenueHeroImage(imageName: venue.imageName, title: venue.city, subtitle: venue.surface)

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.lbtBasqueDeepGreen)
                    Image(systemName: "sportscourt")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.lbtBasqueIvory)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(venue.name)
                            .font(.headline)
                            .foregroundStyle(Color.lbtBasqueBlack)
                        Spacer()
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? Color.lbtBasqueGold : Color.lbtBasqueMuted.opacity(0.65))
                    }
                    Text("\(venue.city), \(venue.region)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.lbtBasqueGreen)
                    Text(venue.bestFor)
                        .font(.callout)
                        .foregroundStyle(Color.lbtBasqueBlack.opacity(0.72))
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                MiniStat(value: venue.founded, label: "profile")
                MiniStat(value: venue.members, label: "scale")
            }

            FlowTags(tags: venue.disciplines)
            SourceBadge(text: venue.source)
        }
        .lbtBasqueCard()
    }
}

private struct VenueDetailView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    let venue: Venue

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VenueHeroImage(imageName: venue.imageName, title: venue.city, subtitle: venue.name)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(venue.name)
                            .font(.title2.weight(.black))
                        Spacer()
                        Button {
                            store.toggleFavorite(venue)
                        } label: {
                            Image(systemName: store.favoriteVenueIDs.contains(venue.id) ? "star.fill" : "star")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.lbtBasqueGreen)
                    }
                    Text("\(venue.city), \(venue.region)")
                        .foregroundStyle(Color.lbtBasqueMuted)
                    FlowTags(tags: venue.disciplines)
                    SourceBadge(text: venue.source)
                }
                .lbtBasqueCard()

                InfoBlock(title: "Best for", icon: "target", text: venue.bestFor)
                InfoBlock(title: "Surface", icon: "rectangle.dashed", text: venue.surface)
                InfoBlock(title: "Level", icon: "gauge.with.dots.needle.bottom.50percent", text: venue.level)
                InfoBlock(title: "Location hint", icon: "mappin", text: venue.addressHint)
                InfoBlock(title: "Session note", icon: "note.text", text: venue.note)
                InfoListBlock(title: "Real club notes", icon: "checklist", items: venue.highlights)
                InfoBlock(title: "Image credit", icon: "camera", text: venue.imageCredit)
                Link(destination: URL(string: venue.website)!) {
                    Label("Open official page", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(LBTBasquePrimaryButton())
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .lbtBasqueScreen()
            .navigationTitle(venue.city)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct TrainingView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    @State private var selectedDrillID = LBTBasqueData.drills[0].id
    @State private var effort = 3
    @State private var note = ""
    @State private var secondsRemaining = LBTBasqueData.drills[0].minutes * 60
    @State private var isRunning = false

    private var selectedDrill: Drill {
        (LBTBasqueData.drills.first { $0.id == selectedDrillID } ?? LBTBasqueData.drills[0]).localized(store.language)
    }

    private var drills: [Drill] {
        LBTBasqueData.drills.map { $0.localized(store.language) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    WeekProgressCard()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(L10n.text("drillPicker", store.language))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(drills) { drill in
                                    DrillChoiceCard(drill: drill, isSelected: drill.id == selectedDrillID) {
                                        selectedDrillID = drill.id
                                        resetTimer()
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                SectionTitle(L10n.text("drillTimer", store.language))
                                Text(selectedDrill.summary)
                                    .font(.callout)
                                    .foregroundStyle(Color.lbtBasqueBlack.opacity(0.76))
                            }
                            Spacer()
                            IntensityBadge(value: selectedDrill.intensity, language: store.language)
                        }

                        DrillDiagramView(kind: selectedDrill.diagram)

                        Text(timeText)
                            .font(.system(size: 54, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .frame(maxWidth: .infinity)

                        HStack(spacing: 10) {
                            Button {
                                isRunning.toggle()
                            } label: {
                                Label(isRunning ? L10n.text("pause", store.language) : L10n.text("start", store.language), systemImage: isRunning ? "pause.fill" : "play.fill")
                            }
                            .buttonStyle(LBTBasquePrimaryButton())

                            Button {
                                resetTimer()
                            } label: {
                                Label(L10n.text("reset", store.language), systemImage: "arrow.counterclockwise")
                            }
                            .buttonStyle(LBTBasqueSecondaryButton())
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            MiniStat(value: selectedDrill.equipment, label: L10n.text("equipment", store.language))
                            MiniStat(value: selectedDrill.target, label: L10n.text("target", store.language))
                        }

                        InfoListBlock(title: L10n.text("howToDo", store.language), icon: "figure.run", items: selectedDrill.steps)
                        InfoListBlock(title: L10n.text("avoid", store.language), icon: "exclamationmark.triangle", items: selectedDrill.mistakes)

                        Stepper("\(L10n.text("intensity", store.language)) \(effort)/5", value: $effort, in: 1...5)
                        TextField(L10n.text("trainingNote", store.language), text: $note, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            logTraining()
                        } label: {
                            Label(L10n.text("logTraining", store.language), systemImage: "checkmark.seal.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(LBTBasquePrimaryButton())
                    }
                    .lbtBasqueCard()

                    TrainingHistoryCard()
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .lbtBasqueScreen()
            .navigationTitle(L10n.text("train", store.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isRunning, secondsRemaining > 0 else { return }
            secondsRemaining -= 1
            if secondsRemaining == 0 {
                isRunning = false
            }
        }
    }

    private var timeText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func resetTimer() {
        isRunning = false
        secondsRemaining = selectedDrill.minutes * 60
    }

    private func logTraining() {
        let elapsed = max(1, selectedDrill.minutes - secondsRemaining / 60)
        store.addTrainingLog(TrainingLog(id: UUID(), date: Date(), drillID: selectedDrill.id, minutes: elapsed, perceivedEffort: effort, note: note))
        note = ""
        resetTimer()
    }
}

private struct TrainingHistoryCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(L10n.text("trainingHistory", store.language))
            if store.trainingLogs.isEmpty {
                EmptyStateRow(icon: "timer", title: L10n.text("noTraining", store.language), text: L10n.text("runDrill", store.language))
            } else {
                ForEach(store.trainingLogs.prefix(6)) { log in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(drillTitle(log.drillID))
                                .font(.headline)
                            Text(log.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(Color.lbtBasqueMuted)
                        }
                        Spacer()
                        Text("\(log.minutes) min")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(Color.lbtBasqueGreen)
                    }
                }
            }
        }
        .lbtBasqueCard()
    }

    private func drillTitle(_ id: String) -> String {
        LBTBasqueData.drills.first { $0.id == id }?.localized(store.language).title ?? L10n.text("train", store.language)
    }
}

private struct DrillChoiceCard: View {
    let drill: Drill
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: drillIcon)
                        .font(.headline)
                    Spacer()
                    Text("\(drill.minutes) min")
                        .font(.caption.weight(.black))
                }
                Text(drill.title)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(drill.focus)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? .white.opacity(0.78) : Color.lbtBasqueGreen)
            }
            .padding(12)
            .frame(width: 156, height: 128, alignment: .topLeading)
            .background(isSelected ? Color.lbtBasqueBlack : Color.lbtBasquePaper)
            .foregroundStyle(isSelected ? .white : Color.lbtBasqueBlack)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.lbtBasqueGold.opacity(0.55) : Color.white.opacity(0.65), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var drillIcon: String {
        switch drill.diagram {
        case "corridor": "arrow.up.forward.square"
        case "rebound": "arrow.triangle.2.circlepath"
        case "touch": "hand.tap"
        case "choice": "point.3.connected.trianglepath.dotted"
        default: "scope"
        }
    }
}

private struct IntensityBadge: View {
    let value: Int
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 4) {
            Text(L10n.text("intensity", language))
                .font(.caption2.weight(.bold))
            Text("\(value)/5")
                .font(.headline.monospacedDigit())
        }
        .foregroundStyle(Color.lbtBasqueGold)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.lbtBasqueGold.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DrillDiagramView: View {
    let kind: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.lbtBasqueDeepGreen, Color.lbtBasqueBlack], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            CourtLines()
                .stroke(.white.opacity(0.25), lineWidth: 2)
                .padding(18)
            diagramMarks
        }
        .frame(height: 176)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.34), lineWidth: 1)
        )
    }

    @ViewBuilder private var diagramMarks: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            switch kind {
            case "corridor":
                Path { path in
                    path.move(to: CGPoint(x: width * 0.42, y: height * 0.78))
                    path.addLine(to: CGPoint(x: width * 0.58, y: height * 0.28))
                }
                .stroke(Color.lbtBasqueGold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.lbtBasqueGold.opacity(0.9), lineWidth: 3)
                    .frame(width: width * 0.22, height: height * 0.46)
                    .position(x: width * 0.58, y: height * 0.48)
            case "rebound":
                Path { path in
                    path.move(to: CGPoint(x: width * 0.30, y: height * 0.76))
                    path.addLine(to: CGPoint(x: width * 0.20, y: height * 0.38))
                    path.addLine(to: CGPoint(x: width * 0.70, y: height * 0.26))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.72))
                }
                .stroke(Color.lbtBasqueGold, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [8, 7]))
            case "touch":
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .stroke(Color.lbtBasqueGold.opacity(0.85), lineWidth: 3)
                        .frame(width: 18 + CGFloat(index * 10), height: 18 + CGFloat(index * 10))
                        .position(x: width * 0.30 + CGFloat(index * 26), y: height * 0.48)
                }
            case "choice":
                Path { path in
                    path.move(to: CGPoint(x: width * 0.50, y: height * 0.78))
                    path.addLine(to: CGPoint(x: width * 0.30, y: height * 0.28))
                    path.move(to: CGPoint(x: width * 0.50, y: height * 0.78))
                    path.addLine(to: CGPoint(x: width * 0.72, y: height * 0.32))
                }
                .stroke(Color.lbtBasqueGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                Circle().fill(Color.lbtBasqueGold).frame(width: 16, height: 16).position(x: width * 0.30, y: height * 0.28)
                Circle().fill(Color.lbtBasqueGold).frame(width: 16, height: 16).position(x: width * 0.72, y: height * 0.32)
            default:
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.lbtBasqueGold.opacity(0.82))
                        .frame(width: width * 0.62, height: 8)
                        .position(x: width * 0.50, y: height * (0.30 + Double(index) * 0.17))
                }
            }
        }
    }
}

private struct CourtLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 8, height: 8))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.28))
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.70))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.70))
        return path
    }
}

private struct RulesView: View {
    @EnvironmentObject private var store: LBTBasqueStore
    @State private var searchText = ""
    @State private var expandedRuleIDs: Set<String> = ["rally"]

    private var rules: [RuleCard] {
        LBTBasqueData.rules.map { $0.localized(store.language) }.filter { rule in
            searchText.isEmpty || "\(rule.title) \(rule.summary) \(rule.details.joined(separator: " "))".localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    RulesHeroCard()
                    PremiumSearchField(text: $searchText, prompt: L10n.text("searchRules", store.language))

                    ForEach(rules) { card in
                        RulePremiumCard(card: card, isExpanded: expandedRuleIDs.contains(card.id)) {
                            if expandedRuleIDs.contains(card.id) {
                                expandedRuleIDs.remove(card.id)
                            } else {
                                expandedRuleIDs.insert(card.id)
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .lbtBasqueScreen()
            .navigationTitle(L10n.text("rules", store.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct RulesHeroCard: View {
    @EnvironmentObject private var store: LBTBasqueStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(Color.lbtBasqueGold)
                Spacer()
                Text(L10n.text("guide", store.language))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.lbtBasqueGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.lbtBasqueGold.opacity(0.14))
                    .clipShape(Capsule())
            }
            RuleDiagramView(kind: "court")
                .frame(height: 118)
                .padding(.vertical, 4)
            Text(L10n.text("knowCourt", store.language))
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
            Text(L10n.text("fastReference", store.language))
                .font(.callout)
                .foregroundStyle(.white.opacity(0.76))
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.lbtBasqueBlack, Color.lbtBasqueDeepGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct RulePremiumCard: View {
    @EnvironmentObject private var store: LBTBasqueStore
    let card: RuleCard
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: toggle) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(card.title)
                            .font(.headline)
                            .foregroundStyle(Color.lbtBasqueBlack)
                        Text(card.summary)
                            .font(.subheadline)
                            .foregroundStyle(Color.lbtBasqueMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .font(.title3)
                        .foregroundStyle(isExpanded ? Color.lbtBasqueGreen : Color.lbtBasqueMuted)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                RuleDiagramView(kind: card.diagram)
                    .frame(height: 150)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(card.details, id: \.self) { detail in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.lbtBasqueGreen)
                                .font(.callout)
                                .padding(.top, 2)
                            Text(detail)
                                .font(.callout)
                                .foregroundStyle(Color.lbtBasqueBlack.opacity(0.78))
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.text("keyChecks", store.language))
                        .font(.subheadline.weight(.black))
                    FlowTags(tags: card.checkpoints)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy(duration: 0.18), value: isExpanded)
        .lbtBasqueCard()
    }
}

private struct RuleDiagramView: View {
    let kind: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.lbtBasqueDeepGreen.opacity(0.95))
            CourtLines()
                .stroke(.white.opacity(0.24), lineWidth: 2)
                .padding(12)
            ruleMarks
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lbtBasqueGold.opacity(0.35), lineWidth: 1)
        )
    }

    @ViewBuilder private var ruleMarks: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            switch kind {
            case "formats":
                HStack(spacing: 10) {
                    ForEach(["TRI", "M G", "JAI"], id: \.self) { label in
                        VStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.lbtBasqueGold, lineWidth: 2)
                                .frame(height: 42)
                            Text(label)
                                .font(.caption2.weight(.black))
                                .foregroundStyle(Color.lbtBasqueGold)
                        }
                    }
                }
                .padding(16)
            case "rally":
                Path { path in
                    path.move(to: CGPoint(x: width * 0.18, y: height * 0.74))
                    path.addQuadCurve(to: CGPoint(x: width * 0.82, y: height * 0.30), control: CGPoint(x: width * 0.46, y: height * 0.12))
                    path.addQuadCurve(to: CGPoint(x: width * 0.36, y: height * 0.68), control: CGPoint(x: width * 0.62, y: height * 0.52))
                }
                .stroke(Color.lbtBasqueGold, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 6]))
                Circle().fill(Color.lbtBasqueGold).frame(width: 14, height: 14).position(x: width * 0.82, y: height * 0.30)
            case "score":
                HStack(spacing: 12) {
                    ForEach(["25", "30", "35", "40"], id: \.self) { target in
                        Text(target)
                            .font(.headline.monospacedDigit().weight(.black))
                            .foregroundStyle(Color.lbtBasqueGold)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case "safety":
                Path { path in
                    path.move(to: CGPoint(x: width * 0.22, y: height * 0.72))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.32))
                    path.addLine(to: CGPoint(x: width * 0.78, y: height * 0.72))
                }
                .stroke(Color.lbtBasqueGold, lineWidth: 4)
                Text("!")
                    .font(.title.weight(.black))
                    .foregroundStyle(Color.lbtBasqueGold)
                    .position(x: width * 0.50, y: height * 0.58)
            case "gear":
                HStack(spacing: 18) {
                    Image(systemName: "circle.fill")
                    Image(systemName: "shoeprints.fill")
                    Image(systemName: "eye.fill")
                }
                .font(.title.weight(.bold))
                .foregroundStyle(Color.lbtBasqueGold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.lbtBasqueGold)
                        .frame(width: width * 0.62, height: 7)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.lbtBasqueGold.opacity(0.78))
                        .frame(width: width * 0.46, height: 7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

private struct MatchRow: View {
    let match: MatchRecord

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(match.homeName) vs \(match.awayName)")
                    .font(.headline)
                Text("\(match.discipline) - \(match.rallyCount) rallies - \(match.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(Color.lbtBasqueMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(match.scoreline)
                    .font(.title3.weight(.black).monospacedDigit())
                Text(match.winnerName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.lbtBasqueGreen)
            }
        }
    }
}

private struct VenueHeroImage: View {
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 138)
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(colors: [.black.opacity(0.02), .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.black))
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .opacity(0.86)
            }
            .foregroundStyle(.white)
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct InfoBlock: View {
    let title: String
    let icon: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            Text(text)
                .font(.callout)
                .foregroundStyle(Color.lbtBasqueBlack.opacity(0.78))
        }
        .lbtBasqueCard()
    }
}

private struct InfoListBlock: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.lbtBasqueGreen)
                        .padding(.top, 1)
                    Text(item)
                        .font(.callout)
                        .foregroundStyle(Color.lbtBasqueBlack.opacity(0.78))
                }
            }
        }
        .lbtBasqueCard()
    }
}

private struct SourceBadge: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "checkmark.shield.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.lbtBasqueGold)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
}

private struct EmptyStateRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.lbtBasqueGreen)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Color.lbtBasqueMuted)
            }
        }
    }
}

private struct PremiumSearchField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(Color.lbtBasqueMuted)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.lbtBasqueMuted.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.lbtBasqueIvory)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.lbtBasqueIvory : Color.white.opacity(0.12))
                .foregroundStyle(isSelected ? Color.lbtBasqueGreen : Color.lbtBasqueIvory)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.lbtBasqueGold.opacity(0.35) : Color.white.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MetricCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.lbtBasqueGreen)
            Text(value)
                .font(.title.weight(.black).monospacedDigit())
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.lbtBasqueMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lbtBasqueCard()
    }
}

private struct MiniStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.subheadline.weight(.black))
                .foregroundStyle(Color.lbtBasqueBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.lbtBasqueMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack { tagViews }
            VStack(alignment: .leading) { tagViews }
        }
    }

    @ViewBuilder private var tagViews: some View {
        ForEach(tags, id: \.self) { tag in
            Pill(tag)
        }
    }
}

private struct Pill: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.lbtBasqueGreen.opacity(0.12))
            .foregroundStyle(Color.lbtBasqueGreen)
            .clipShape(Capsule())
    }
}

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.lbtBasqueBlack)
    }
}

private struct LBTBasqueLogo: View {
    let size: CGFloat

    var body: some View {
        Image("BrandLogo")
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
        .frame(width: size, height: size)
    }
}

private struct LBTBasquePrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(configuration.isPressed ? Color.lbtBasqueDeepGreen : Color.lbtBasqueGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LBTBasqueSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(configuration.isPressed ? Color.lbtBasqueGold.opacity(0.18) : Color.lbtBasqueIvory)
            .foregroundStyle(Color.lbtBasqueBlack)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}

private extension View {
    func lbtBasqueCard() -> some View {
        self
            .padding(14)
            .background(Color.lbtBasquePaper)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    func lbtBasqueScreen() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [Color.lbtBasqueFieldTop, Color.lbtBasqueField, Color.lbtBasqueDeepGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

#Preview {
    LBTBasqueContentView()
}
