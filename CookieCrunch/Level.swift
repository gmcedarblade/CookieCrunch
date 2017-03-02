//
//  Level.swift
//  CookieCrunch
//
//  Created by Gregory Cedarblade on 2/23/17.
//  Copyright © 2017 Gregory Cedarblade. All rights reserved.
//

import Foundation

let numColumns = 9
let numRows = 9

class Level {
  
  fileprivate var cookies = Array2D<Cookie>(columns: numColumns, rows: numRows)
  
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
  
  private var possibleSwaps = Set<Swap>()
  
  init(fileName: String) {
    
    guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(fileName: fileName) else { return }
    
    guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
    
    for (row, rowArray) in tilesArray.enumerated() {
      
      let tileRow = numRows - row - 1
      
      for (column, value) in rowArray.enumerated() {
        
        if value == 1 {
          
          tiles[column, tileRow] = Tile()
          
        }
        
      }
      
    }
    
  }
  
  func cookieAt(column: Int, row: Int) -> Cookie? {
    assert(column >= 0 && column < numColumns)
    assert(row >= 0 && row < numRows)
    
    return cookies[column, row]
  }
  
  func tileAt(column: Int, row: Int) -> Tile? {
    assert(column >= 0 && column < numColumns)
    assert(row >= 0 && row < numRows)
    
    return tiles[column, row]
  }
  
  func shuffle() -> Set<Cookie> {
    
    var set: Set<Cookie>
    
    repeat {
      
      set = createInitialCookies()
      
      detectPossibleSwaps()
      
      print("possible swaps: \(possibleSwaps)")
      
    } while possibleSwaps.count == 0
    
    return set
  }
  
  private func createInitialCookies() -> Set<Cookie> {
    
    var set = Set<Cookie>()
    
    for row in 0..<numRows {
      
      for column in 0..<numColumns {
        
        if tiles[column, row] != nil {
          
          var cookieType: CookieType
          
          repeat {
            
            cookieType = CookieType.random()
            
          } while (
            column >= 2 &&
              cookies[column - 1, row]?.cookieType == cookieType &&
              cookies[column - 2, row]?.cookieType == cookieType
            )
            || (
              row >= 2 &&
              cookies[column, row - 1]?.cookieType == cookieType &&
              cookies[column, row - 2]?.cookieType == cookieType
          )
          
          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
          
          cookies[column, row] = cookie
          
          set.insert(cookie)
          
        }
        
      }
      
    }
    
    return set
    
  }
  
  // MARK: - Possible Swaps
  
  func detectPossibleSwaps() {

    var set = Set<Swap>()
    
    for row in 0..<numRows {
      
      for column in 0..<numColumns {
        
        if let cookie = cookies[column, row] {
          
          // Look for swaps
          
          // Is it possible to swap this cookie with the one on the right
          if column < numColumns - 1 {
            
            if let otherCookie = cookies[column + 1, row] {
              
              // Swap the cookies
              cookies[column, row] = otherCookie
              cookies[column + 1, row] = cookie
              
              // Are they part of a chain?
              if hasChainAt(column: column + 1, row: row)
                || hasChainAt(column: column, row: row) {
                set.insert(Swap(cookieA: cookie, cookieB: otherCookie))
              }
              
              // Swap them back
              cookies[column, row] = cookie
              cookies[column + 1, row] = otherCookie
              
            }
            
          }
          
          // Is it possible to swap this cookie with the one above it
          if row < numRows - 1 {
            
            if let otherCookie = cookies[column, row + 1] {
              
              // Swap the cookies
              cookies[column, row] = otherCookie
              cookies[column, row + 1] = cookie
              
              // Are they part of a chain?
              if hasChainAt(column: column, row: row + 1)
                || hasChainAt(column: column, row: row) {
                
                set.insert(Swap(cookieA: cookie, cookieB: otherCookie))
                
              }
              
              // Swap them back
              cookies[column, row] = cookie
              cookies[column, row + 1] = otherCookie
              
            }
            
          }
          
        }
        
      }
      
    }
  
    possibleSwaps = set
  }
  
  private func hasChainAt(column: Int, row: Int) -> Bool {
    
    let cookieType = cookies[column, row]!.cookieType
    
    // Horizontal Chains
    var horzLength = 1
    
    // Look Left
    var i = column - 1
    while i >= 0 && cookies[i, row]?.cookieType == cookieType {
      
      i -= 1
      horzLength += 1
      
    }
    
    // Look Right
    
    i = column + 1
    while i < numColumns && cookies[i, row]?.cookieType == cookieType {
      
      i += 1
      horzLength += 1
      
    }
    
    if horzLength >= 3 { return true }
    
    // Vertical Chains
    var vertLength = 1
    
    // Look Down
    i = row - 1
    while i >= 0 && cookies[column, i]?.cookieType == cookieType {
      
      i -= 1
      vertLength += 1
      
    }
    
    // Look Up
    i = row + 1
    while i < numRows && cookies[column, i]?.cookieType == cookieType {
      
      i += 1
      vertLength += 1
      
    }
    
    return vertLength >= 3
    
  }
  
  func isPossibleSwap(_ swap: Swap) -> Bool {
    
    return possibleSwaps.contains(swap)
    
  }
  
  // MARK: - Perform Swap
  
  func performSwap(swap: Swap) {
    
    let columnA = swap.cookieA.column
    let rowA = swap.cookieA.row
    let columnB = swap.cookieB.column
    let rowB = swap.cookieB.row
    
    cookies[columnA, rowA] = swap.cookieB
    swap.cookieB.column = columnA
    swap.cookieB.row = rowA
    
    cookies[columnB, rowB] = swap.cookieA
    swap.cookieA.column = columnB
    swap.cookieA.row = rowB
    
  }
  
  
  // MARK: - Remove Matches
  
  func removeMatches() -> Set<Chain> {
    fatalError()
  }
  
  
  private func detectHorizontalMatches() -> Set<Chain> {
    
    var set = Set<Chain>()
    
    for row in 0..<numRows {
     
      var column = 0
      
      while column < numColumns - 2 { // don't check the last two columns
        
        if let cookie = cookies[column, row] {
          
          let matchType = cookie.cookieType
          
          if cookies[column + 1, row]?.cookieType == matchType
            && cookies[column + 1, row]?.cookieType == matchType {
            
            let chain = Chain(chainType: .horizontal)
            
            repeat {
              
              chain.add(cookie: cookies[column, row]!)
              column += 1
              
            } while column < numColumns && cookies[column, row]?.cookieType == matchType
           
            set.insert(chain)
            continue
          }
          
        }
        
        column += 1
        
      }
      
    }
    
    return set
    
  }
  
  
}
