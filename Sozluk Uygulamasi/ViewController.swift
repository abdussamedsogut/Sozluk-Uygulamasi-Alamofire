//
//  ViewController.swift
//  Sozluk Uygulamasi
//
//  Created by Abdüssamed Söğüt on 22.02.2023.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var kelimeTableView: UITableView!
    
    var kelimeListesi = [Kelimeler]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kelimeTableView.delegate = self
        kelimeTableView.dataSource = self
        
        searchBar.delegate = self
        
        tumKelimelerAl()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indeks = sender as? Int
        let gidilecekVC = segue.destination as! KelimeDetayViewController
        
        gidilecekVC.kelime = kelimeListesi[indeks!]
        
    }
    
    
    func tumKelimelerAl() {
        
        guard let url = URL(string: "http://kasimadalan.pe.hu/sozluk/tum_kelimeler.php") else { return }
        let request = AF.request(url, method: .get)
        
        request.response { response in
            guard let data = response.data else { return }
            
            do {
                let cevap = try JSONDecoder().decode(SozlukCevap.self, from: data)
                
                if let gelenKelimeListesi = cevap.kelimeler {
                    self.kelimeListesi = gelenKelimeListesi
                }
                DispatchQueue.main.async {
                    self.kelimeTableView.reloadData()
                }
                
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
    
    func aramaYap(aramaKelimesi:String) {
        
        let params: Parameters = ["ingilizce":aramaKelimesi]
        
        AF.request("http://kasimadalan.pe.hu/sozluk/kelime_ara.php", method: .post, parameters: params).response { response in
            if let data = response.data {
                
                do {
                    let cevap = try JSONDecoder().decode(SozlukCevap.self, from: data)
                    
                    if let gelenKelimeListesi = cevap.kelimeler {
                        self.kelimeListesi = gelenKelimeListesi
                    }
                    DispatchQueue.main.async {
                        self.kelimeTableView.reloadData()
                    }
                    
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
}
    

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kelimeListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let kelime = kelimeListesi[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelimeHucre", for: indexPath) as! KelimeHucreTableViewCell
        
        cell.turkceLabel.text = kelime.turkce
        cell.ingilizceLabel.text = kelime.ingilizce
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.performSegue(withIdentifier: "toKelimeDetay", sender: indexPath.row)
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        aramaYap(aramaKelimesi: searchText)
    }
}
