//
//  PassTheTestCVC.swift
//  HighTime
//
//  Created by Mairambek on 21/08/2019.
//  Copyright © 2019 Sunrise. All rights reserved.
//

import UIKit
import RxSwift
import PKHUD
import MBRadioButton
import MMProgressHUD


class PassTheTestCVC: UICollectionViewController {
    
    //    MARK:    Variables
    //    MARK:    Переменные
    var questions = [PassTestModel]()
    var testVM = TestViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Пройдите тест"
        HUD.show(.progress)
        collectionView.allowsSelection = false
    
        subscribeBehaviorRaplays()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeBehaviorRaplays()
    }
    
    
    func subscribeBehaviorRaplays(){
        self.testVM.getTest { (error) in
            if error != nil {
                HUD.hide()
                MMProgressHUD.show()
                MMProgressHUD.dismissWithError(error?.localizedDescription)
            }
        }
        
        self.testVM.testBehaviorRelay.skip(1).subscribe(onNext: { (questions) in
            self.questions = questions
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            HUD.hide()
        }).disposed(by: disposeBag)
       
        self.testVM.errorBehaviorRelay.skip(1).subscribe(onNext: { (error) in
            print(error.localizedDescription)
            HUD.hide()
            
        }).disposed(by: disposeBag)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return questions.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == questions.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoneTestCVCell", for: indexPath) as! DoneTestCVCell
            cell.doneButton.addTarget(self, action: #selector(doneButtonClicked(sender:)), for: .touchUpInside)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PassTheTestCVCell", for: indexPath) as! PassTheTestCVCell
        
        cell.link = self
        
        let question = self.questions[indexPath.row]
        
        //присваивание title button'aм
        for i in 0..<5{
            if i < question.answers.count {
                cell.answersButtonArray[i].setTitle(question.answers[i].title, for: .normal)
                cell.answersButtonArray[i].isHidden = false
            } else {
                cell.answersButtonArray[i].isHidden = true
            }
        }
        
        self.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? PassTheTestCVCell else {return}
        let question = self.questions[indexPath.row]
        cell.titleQuestion.text = question.title
        cell.contentQuestion.text = question.content
        
        if question.selected != 0 {
            let selectNum = question.selected - 1
            cell.viewContainerCell.selectedButton = cell.answersButtonArray[selectNum]
        } else {
            cell.viewContainerCell.selectedButton = nil
        }
        
    }
    
    //MARK: Button Clicked
    func didTappedAnswerButton(answerButton:RadioButton,cell:UICollectionViewCell){
        guard let  indexPathTapped = collectionView.indexPath(for: cell) else {return}
        
        questions[indexPathTapped.row].selected = answerButton.tag
        let answerIndex = answerButton.tag - 1
        if questions[indexPathTapped.row].answers[answerIndex].isCorrect == true {
            questions[indexPathTapped.row].isCorrect = true
        } else {
            questions[indexPathTapped.row].isCorrect = false
        }
    }
    
    @objc func doneButtonClicked(sender:UIButton){

        var corectAnswersNum = 0
        
        for i in 0..<questions.count{
        
            if questions[i].isCorrect == true {
                corectAnswersNum += 1
                
            } else if questions[i].isCorrect == false {
            } else if questions[i].isCorrect == nil {
                Alert.displayAlert(title: "Ошибка", message: "Ответьте на все вопросы", vc: self)
                return
            }
        }
        let token = UserDefaults.standard.value(forKey: "userToken") as! String
        if corectAnswersNum < 4 {
            UserDefaults.standard.set(0, forKey: "\(token)myLevel")
        } else if corectAnswersNum >= 4 && corectAnswersNum < 7 { UserDefaults.standard.set(1, forKey: "\(token)myLevel")
        } else if corectAnswersNum >= 7 && corectAnswersNum < 10 {
            UserDefaults.standard.set(2, forKey: "\(token)myLevel")
        } else if corectAnswersNum >= 10 && corectAnswersNum < 12 {
            UserDefaults.standard.set(3, forKey: "\(token)myLevel")
        } else if corectAnswersNum == 12 {
            UserDefaults.standard.set(4, forKey: "\(token)myLevel")
        } else if corectAnswersNum > 12 {
            UserDefaults.standard.set(5, forKey: "\(token)myLevel")
        }
        
        let levelVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LevelsVC") as! LevelsVC
         navigationController?.pushViewController(levelVC, animated: true)
        
    }

    
}


extension PassTheTestCVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == questions.count {
            return CGSize(width: view.frame.width, height: 100)
        }
        let question = self.questions[indexPath.row]
        if question.answers.count == 2 {
            return CGSize(width: view.frame.width, height: 165)
        } else if  question.answers.count == 3 {
            return CGSize(width: view.frame.width, height: 200)
        } else if question.answers.count == 4 {
            return CGSize(width: view.frame.width, height: 235)
        } else if question.answers.count == 5 {
            return CGSize(width: view.frame.width, height: 270)
        } else {
            return CGSize(width: view.frame.width, height: 158)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 0)
    }
    
}
