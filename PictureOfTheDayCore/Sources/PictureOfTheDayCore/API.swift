import SwiftDotenv
import Dependencies
import EverythingButTheBagelCore
import Foundation

/*
 {
 "copyright": "\nS. Kohle, T. Credner et al.\n(AIUB)\n",
 "date": "1998-02-08",
 "explanation": "The Crab Nebula, filled with mysterious filaments, is the result of a star that exploded in 1054 AD.  This spectacular supernova explosion was recorded by Chinese and (quite probably) Anasazi Indian astronomers.  The filaments are mysterious because they appear to have less mass than expelled in the original supernova and higher speed than expected from a free explosion. In the above picture, the color indicates what is happening to the electrons in different parts of the Crab Nebula. Red indicates the electrons are recombining with protons to form neutral hydrogen, while green indicates the electrons are whirling around the magnetic field of the inner nebula. In the nebula's very center lies a pulsar: a neutron star rotating, in this case, 30 times a second.",
 "hdurl": "https://apod.nasa.gov/apod/image/9702/m1crab_kc_big.jpg",
 "media_type": "image",
 "service_version": "v1",
 "title": "M1: Filaments of the Crab Nebula",
 "url": "https://apod.nasa.gov/apod/image/9702/m1crab_kc.jpg"
 }
 */

public struct POTDResponseModel: Codable, Equatable {
  let copyright: String
  let date: Date
  let explanation: String
  let hdurl: URL
  let mediaType: String
  let serviceVersion: String
  let title: String
  let url: URL

  enum CodingKeys: String, CodingKey {
    case copyright
    case date
    case explanation
    case hdurl
    case mediaType = "media_type"
    case serviceVersion = "service_version"
    case title
    case url
  }
}
