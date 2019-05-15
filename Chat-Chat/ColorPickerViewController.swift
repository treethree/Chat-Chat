import UIKit
import ViewAnimator

class ColorPickerViewController: UICollectionViewController
{
    let reuseIdentifier = "ColorPickerCell"
    let columnCount = 2
    let margin : CGFloat = 10
    
    @IBOutlet var colView: UICollectionView!
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ViewHelper.setCollectionViewLayout(collectionView: collectionView, margin: margin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let randomAnimation = AnimationType.random()

        colView.performBatchUpdates({
            UIView.animate(views: colView.visibleCells,
                           animations: [randomAnimation],
                           duration: 0.5)
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource protocol
extension ColorPickerViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.colors.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        cell.backgroundColor = Constants.colors[indexPath.item]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension ColorPickerViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var userData =  UserData()
        userData.colorId = indexPath.item
        userData.save()
        self.navigationController?.popViewController(animated: true)
    }
}

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(columnCount - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(columnCount)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
