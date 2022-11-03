//
//  SearchViewController.swift
//  RecipeApp
//

import UIKit


class SearchViewController : UIViewController {
    
    // app delegate instance
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // view safe area
    var safeAreaGuide: UILayoutGuide!
    
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchButton: UIButton!
    
    // table view
    var tableView: UITableView = UITableView()
    
    // list of all serach result recipes -- init to blank
    var searchResultRecipes: [Recipe] = [Recipe]()
    var allRecipes: [Recipe] = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure safe area
        safeAreaGuide = view.layoutMarginsGuide
        
        // configure table vie
        configureTableView()
        
        allRecipes = mainDelegate.recipeListWithPriceAndLikes
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: "recipe_cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchButton!.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let searchValue = searchText.text
        
        searchResultRecipes = allRecipes.filter {
            $0.name!.contains(searchValue!) ||
            $0.details!.contains(searchValue!) ||
            $0.ingredients!.contains(searchValue!)
        }
        
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath)
        
        // conform UITableViewCell (cell) to RecipeTableViewCell
        guard let recipeCell = cell as? RecipeTableViewCell else {
            return cell
        }
        
        let recipeItem = searchResultRecipes[indexPath.row]
        
        // check if recipe img is a URL
        if let recipeImageURL = URL(string: recipeItem.img!) {
            // add the recipe img from the url to the UIImageView
            recipeCell.imageViewItem.loadImage(from: recipeImageURL)
        }
        
        // set the rest of the properties for each tableView cell (RecipeTableViewCell)
        recipeCell.recipeNameLabel.text = recipeItem.name
        
        // check if the recipe price is FREE
        if recipeItem.price != 0 {
            recipeCell.recipePriceLabel.text = "$\(String(recipeItem.price!)) CAD"
        } else {
            recipeCell.recipePriceLabel.text = "FREE"
        }
        
        if recipeItem.likes == 0 {
            recipeCell.recipeLikesLabel.text = "No likes"
        } else if recipeItem.likes == 1 {
            recipeCell.recipeLikesLabel.text = "\(String(recipeItem.likes!)) like"
        } else {
            recipeCell.recipeLikesLabel.text = "\(String(recipeItem.likes!)) likes"
        }
        
        // add excerpt for the recipe (make sure to add elipses)
        recipeCell.recipeExcerptLabel.text = recipeItem.details
        
        // add disclosure indicator
        recipeCell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = searchResultRecipes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "SearchViewToRecipeDetailViewControllerSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        mainDelegate.selectedRecipeForRecipeDetailView = nil
    }
}
