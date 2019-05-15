import UIKit
import ViewAnimator

class AvatarPickerViewController: UICollectionViewController
{
    let avatarCellReuseIdentifier = "AvatarPickerCell"
    let columnCount = 2
    let margin : CGFloat = 10
    let avatarCount = 10
    
    @IBOutlet var colView: UICollectionView!
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ViewHelper.setCollectionViewLayout(collectionView: collectionView, margin: margin)
    }
    override func viewWillAppear(_ animated: Bool) {
        colView?.reloadData()
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        colView.performBatchUpdates({
            UIView.animate(views: colView.visibleCells,
                                 animations: [rotateAnimation],
                                 duration: 0.5)
        }, completion: nil)
    }
    
}



// MARK: - UICollectionViewDataSource protocol
extension AvatarPickerViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: avatarCellReuseIdentifier, for: indexPath as IndexPath) as! AvatarPickerCell
        
        cell.avatarImageView.image = UIImage(named: String(format: "%@%d", Constants.kAvatarImagePrefix, indexPath.item + 1))
        
//        let zoomAnimation = AnimationType.zoom(scale: 0.2)
//        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
//        UIView.animate(views: collectionView.visibleCells,
//                   animations: [zoomAnimation, rotateAnimation],
//                   duration: 0.5)
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension AvatarPickerViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var userData =  UserData()
        userData.avatarId = indexPath.item + 1
        userData.save()
        
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension AvatarPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(columnCount - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(columnCount)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}
