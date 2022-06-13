//
//  ViewController.swift
//  MyProject7 - Notes
//
//  Created by Vitali Vyucheiski on 5/18/22.
//

import UIKit

class ViewController: UITableViewController {
    var notes = [Note]()
    var observer: NSObjectProtocol?
    var VCLoaded = false
    var deleteMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewNote))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteFunc))
        
        save()
        
        VCLoaded = true
        
        //Parsing data from detailVC
        DispatchQueue.main.async {
            self.observer = NotificationCenter.default.addObserver(forName: Notification.Name("noteUpdate"), object: nil, queue: .main, using: { notification in
                
                guard let object = notification.object as? [String: String] else { return }
                
                guard let noteTitlePassed = object["title"] else { return }
                guard let noteBodyPassed = object["body"] else { return }
                guard let noteNumberPassed = object["noteNumber"] else { return }
                let noteNumber = Int(noteNumberPassed)!
                
                self.notes[noteNumber].title = noteTitlePassed
                self.notes[noteNumber].body = noteBodyPassed
                
                self.tableView.reloadData()
                self.save()
            })
        }
    }
    
//Configuring tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = notes[indexPath.row].body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Instantiating and passing data to DetailVC
        
        if deleteMode {
            notes.remove(at: indexPath.row)
            save()
            tableView.reloadData()
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.noteTitle = notes[indexPath.row].title
                vc.noteBody = notes[indexPath.row].body
                vc.noteNumber = indexPath.row
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
//App's Logic
    @objc func addNewNote() {
        if deleteMode { deleteFunc() }
        
        let newNoteTitle = "New Note"
        let newNoteBody = ""
        let newNote = Note(title: newNoteTitle, body: newNoteBody)
        notes.append(newNote)
        tableView.reloadData()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.noteTitle = newNoteTitle
            vc.noteBody = newNoteBody
            vc.noteNumber = notes.count - 1
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//Saving Data
    func save() {
        let jsonEncoder = JSONEncoder()
        let defaults = UserDefaults.standard
        
        if VCLoaded {
            if let savedData = try? jsonEncoder.encode(notes) {
                defaults.set(savedData, forKey: "notes")
            } else { print("Failed to save Notes") }
        } else {
            if let savedMoments = defaults.object(forKey: "notes") as? Data {
                let jsonDecoder = JSONDecoder()

                do {
                    notes = try jsonDecoder.decode([Note].self, from: savedMoments)
                } catch { print("Failed to load Notes") }
            }
        }
    }
    
//Context Menu
    
    
//Delete logic
    @objc func deleteFunc() {
        deleteMode.toggle()
        if deleteMode {
            title = "Delete Note"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(deleteFunc))
        } else {
            title = "Notes"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteFunc))
        }
    }
}

