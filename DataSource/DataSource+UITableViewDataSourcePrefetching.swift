//
//  DataSource+UITableViewDataSourcePrefetching.swift
//  DataSource
//
//  Created by Matthias Buchetics on 06/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

extension DataSource: UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchRows?(indexPaths) ?? fallbackDataSourcePrefetching?.tableView(tableView, prefetchRowsAt: indexPaths)
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelPrefetching?(indexPaths) ?? fallbackDataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: indexPaths)
    }
}
