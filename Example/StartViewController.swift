//
//  StartViewController
//  Example
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class StartViewController: UITableViewController {
    let titles = ["Example 1", "Example 2", "Example 3", "Example 4", "Example 5", "Example 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad() 
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = tableView.indexPathForSelectedRow!.row
        let viewController = segue.destinationViewController as! ExampleTableViewController
        viewController.title = titles[index]
        
        switch (index) {
        case 0:
            viewController.setupExample1()
        case 1:
            viewController.setupExample2()
        case 2:
            viewController.setupExample3()
        case 3:
            viewController.setupExample4()
        case 4:
            viewController.setupExample5()
        case 5:
            viewController.setupExample6()
        default:
            break
        }
    }
}
