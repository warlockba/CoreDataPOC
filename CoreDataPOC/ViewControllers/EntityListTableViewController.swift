//
//  EntityListTableViewController.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 07.05.23.
//

import UIKit
import CoreData

class EntityListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var studentRepository: StudentRepository = {
        let studentRepository = StudentRepository(fetchedResultsControllerDelegate: self)
        return studentRepository
    }()
    
    private var timerGeneration: Bool = false
    
    private var timer = Timer()
    
    @IBOutlet weak var timerButtonOutlet: UIBarButtonItem!
    
    @IBAction func printButtonPressed(_ sender: UIBarButtonItem) {
        if let safeFetchedObjects = studentRepository.fetchedResultsController.fetchedObjects {
            for student in safeFetchedObjects {
                if let safeName = student.name, let safeDate = student.date {
                    print("\(safeName):\(safeDate)")
                }
                else {
                    print("!!!KRAP!!!")
                }
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Entity", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            // add the code to send it to the database (background queue)
            self.studentRepository.addStudent(name: textField.text!, date: Date(), completion: self.addCompletion)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            // add the code for the cancel ... nothing i assume ...
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Entity Name goes here, duh!"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func diceButtonPressed(_ sender: UIBarButtonItem) {
        let randomName = "\(EntityListTableViewController.randomString(length: Int.random(in: 3..<8))) \(EntityListTableViewController.randomString(length: Int.random(in: 3..<8)))"
        self.studentRepository.addStudent(name: randomName, date: Date(), completion: self.addCompletion)
    }
    
    @IBAction func timerButtonPressed(_ sender: UIBarButtonItem) {
        if timerGeneration {
            timerGeneration = false
            timerButtonOutlet.image = UIImage(systemName: "timer.circle")
            // stop the generation
            timer.invalidate()
        }
        else {
            timerGeneration = true
            timerButtonOutlet.image = UIImage(systemName: "timer.circle.fill")
            // start the generation
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [weak self] _ in
                DispatchQueue.main.async {
                    if let safeSelf = self {
                        let randomName = "\(EntityListTableViewController.randomString(length: Int.random(in: 3..<8))) \(EntityListTableViewController.randomString(length: Int.random(in: 3..<8)))"
                        safeSelf.studentRepository.addStudent(name: randomName, date: Date(), completion: safeSelf.addCompletion)
                    }
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        studentRepository.test_rePerformFetch()
        self.title = "Entries: \(studentRepository.fetchedResultsController.fetchedObjects?.count ?? 0)"
        self.tableView.reloadData()
    }
    
    
    private func addCompletion(error: Error?) {
        print("Operation finished: \(String(describing: error))")
    }
    
    private func deleteCompletion(error: Error?) {
        print("Operation finished: \(String(describing: error))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = "Entries: \(studentRepository.fetchedResultsController.fetchedObjects?.count ?? 0)"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return studentRepository.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentRepository.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        
        let student = studentRepository.fetchedResultsController.object(at: indexPath)

        cell.textLabel?.text = student.name
        cell.detailTextLabel?.text = student.date?.description

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            
            self.studentRepository.deleteStudent(student: self.studentRepository.fetchedResultsController.object(at: indexPath), completion: self.deleteCompletion)
            
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Fetch Results Controller Delegate Methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        self.title = "Entries: \(studentRepository.fetchedResultsController.fetchedObjects?.count ?? 0)"
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
