import UIKit

class EditGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let group: Group?
    
    var titleField: UITextField?
    var noteField: UITextField?
    
    var didSaveGroup: ((Group) -> Void)?
    
    init(group: Group?) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = group?.title ?? "새그룹"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss_))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        tableView.backgroundColor = .backgroundView
        tableView.separatorColor = .separator
        tableView.register(UINib(nibName: TextFieldTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        titleField?.becomeFirstResponder()
    }
    
    @objc func dismiss_() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        guard let title = titleField?.text, let note = noteField?.text, !title.isEmpty else { return }

        if let group = group {
            group.title = title
            group.note = note
            didSaveGroup?(group)
        } else {
            let newGroup = Group(title: title, note: note)
            didSaveGroup?(newGroup)
        }
        
        dismiss_()
    }
}

extension EditGroupViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return group != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                titleField = cell.textField
                titleField?.returnKeyType = .next
                titleField?.delegate = self
                cell.label?.text = "그룹명:"
                cell.textField?.placeholder = "그룹의 이름을 입력하세요"
                cell.textField?.text = group?.title
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                noteField = cell.textField
                noteField?.returnKeyType = .done
                noteField?.delegate = self
                cell.label?.text = "설명:"
                cell.textField?.placeholder = "그룹의 설명을 입력하세요"
                cell.textField?.text = group?.note
                return cell
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.reuseIdentifier)
            }
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
            cell.textLabel?.text = "그룹삭제"
            return cell
        }
        
        return UITableViewCell()
    }
}

extension EditGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            let alert = UIAlertController(title: "그룹삭제", message: "그룹을 삭제하시겠습니까? 종목이 같이 삭제 되지 않습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                NotificationCenter.default.post(name: Group.didDelete, object: self.group)
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        view.backgroundColor = .clear
        return view
    }
}

extension EditGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            noteField?.becomeFirstResponder()
        } else if textField == noteField {
            save()
        }
        return true
    }
}
