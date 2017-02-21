//
//  StartViewController
//  Example
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class StartViewController: UITableViewController {
    let titles = [
        "Example 1",
        "Example 2",
        "Example 3",
        "Example 4",
        "Example 5",
        "Example 6"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad() 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let index = indexPath.row
        
        cell.textLabel?.text = titles[index]
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ExampleTableViewController else {
            return
        }
        
        let index = tableView.indexPathForSelectedRow?.row ?? 0
        viewController.title = titles[index]
    }
}
