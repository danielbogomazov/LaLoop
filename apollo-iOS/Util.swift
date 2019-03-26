//
//  Util.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import CoreData

public class Util {
    
    enum entity {
        case recording
        case artist
        case genre
        case label
    }

    struct Color {
        static let backgroundColor: UIColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        static let main: UIColor = UIColor(red: 255/255, green: 221/255, blue: 92/255, alpha: 1)
        static let secondary: UIColor = UIColor(red: 34/255, green: 112/255, blue: 102/255, alpha: 1)
        static let secondaryDark: UIColor = UIColor(red: 38/255, green: 89/255, blue: 97/255, alpha: 1)
    }
    
    struct Constant {
        static let url = "https://apolloios.ddns.net"
        static let followedArtistsKey = "Followed Artists"
    }
    
    static func getCountdownString(until releaseDate: Date) -> String {
        let calendar = NSCalendar.current
        let current = calendar.startOfDay(for: Date())
        let release = calendar.startOfDay(for: releaseDate)
        
        let components = calendar.dateComponents([.day], from: current, to: release)
        
        if components.day! == 0 { return "TODAY" }
        if components.day! == 1 { return "TOMORROW" }
        return "\(components.day!) Days"
    }
    
    /// Checks to see if the year of the recording is the current year + 1999 (recording without a day)
    ///
    /// - Parameter date: release date of the recording pulled from the server
    /// - Returns: True if the current year + 1999 equals the recording's year - False otherwise
    static func noDay(from date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: date))!
        let curr = Int(formatter.string(from: Date()))!
        
        return curr + 1999 == year
    }
    
    /// If the year of the recording is the current year + 1999, then the release day is unknown -- use this to store the release month without the year
    ///
    /// - Parameter date: release date of the recording pulled from the server
    /// - Returns: Correct date with everything accounted for
    static func trueDate(from date: Date) -> String {
        let formatter = DateFormatter()
        
        if noDay(from: date) {
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: date)
            formatter.dateFormat = "yyyy"
            return "\(month) \(Int(formatter.string(from: date))! - 1999)"
        }
        
        formatter.dateFormat = "MMMM dd, YYYY"
        return formatter.string(from: date)
    }
    
    static func replaceCharEntitites(string: String) -> String {
        var newString = string
        newString = newString.replacingOccurrences(of: "&lt;", with: "<", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&gt;", with: ">", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&amp;", with: "&", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&quot;", with: "\"", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&apos;", with: "\'", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&cent;", with: "¢", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&pound;", with: "£", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&yen;", with: "¥", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&euro;", with: "€", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&copy;", with: "©", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&copy;", with: "®", options: .literal, range: nil)
        return newString
    }
    
    /// Removes an artist from the following list
    ///
    /// - Parameter id: ID of the artist to unfollow
    static func unfollowArtist(id: String) {
        guard var followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }
        guard let index = followedArtists.firstIndex(of: id) else { return }
        
        followedArtists.remove(at: index)
        UserDefaults.standard.set(followedArtists, forKey: Util.Constant.followedArtistsKey)
        LocalNotif.removeRecording(id: id)
    }
    
    /// Add an artist to the following list
    ///
    /// - Parameters:
    ///   - id: ID of the artist to follow
    ///   - recording: Recording for which the notification will be made for
    static func followArtist(id: String, recording: Recording) {
        guard var followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }
        
        followedArtists.append(id)
        UserDefaults.standard.set(followedArtists, forKey: Util.Constant.followedArtistsKey)
        LocalNotif.createNewRecording(recording: recording, completionHandler: { (success, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            if !success {
                // TODO
            }
        })
    }
    
    static func isTBA(date: Date) -> Bool {
        guard let years = Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).year else { return false }
        // TODO : years > 1000 is pretty hackish but it will do until the TBA standard is changed from the backend
        return years > 1000 ? true :  false
    }
}

public class DevelopmentUtil {
    
    static func displaySavedCoreData() {
        let recordings = findMatchFor(entity: .recording) as! [Recording]
        let artists = findMatchFor(entity: .artist) as! [Artist]
        let genres = findMatchFor(entity: .genre) as! [Genre]
        let labels = findMatchFor(entity: .label) as! [Label]
        
        print("\n== Saved Recordings ==")
        for recording in recordings {
            print(recording.id)
            print(recording.name)
            print(recording.release_date ?? "TBA")
            print("Num of artists: \(recording.artists.count)")
        }
        
        print("\n== Saved Artists ==")
        for artist in artists {
            print(artist.id)
            print(artist.name)
        }
        
        print("\n== Saved Genres ==")
        for genre in genres {
            print(genre.id)
            print(genre.name)
        }
        
        print("\n== Saved Labels ==")
        for label in labels {
            print(label.id)
            print(label.name)
        }

    }
    
    static func deleteSavedCoreData() {
        var entities = findMatchFor(entity: .recording)
        entities.append(contentsOf: findMatchFor(entity: .artist))
        entities.append(contentsOf: findMatchFor(entity: .genre))
        entities.append(contentsOf: findMatchFor(entity: .label))

        for entity in entities {
            AppDelegate.viewContext.delete(entity)
        }
    }
    
    
    static func findMatchFor(entity: Util.entity) -> [RecordingInformation] {
        switch entity {
        case .recording:
            let request: NSFetchRequest<Recording> = Recording.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .artist:
            let request: NSFetchRequest<Artist> = Artist.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .genre:
            let request: NSFetchRequest<Genre> = Genre.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        default:
            let request: NSFetchRequest<Label> = Label.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        }
    }
}
