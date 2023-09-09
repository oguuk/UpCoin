//
//  UpCoinWidgetLiveActivity.swift
//  UpCoinWidget
//
//  Created by oguuk on 2023/09/07.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct UpCoinWidgetAttributes: ActivityAttributes {
    
    public init(coinName: String) { self.coinName = coinName }
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        
        public init(imageName: String, price: String,
                    tradeVolume: String, fluctuationRate: String,
                    priceFluctuation: String, state: Int) {
            self.imageName = imageName
            self.price = price
            self.tradeVolume = tradeVolume
            self.fluctuationRate = fluctuationRate
            self.priceFluctuation = priceFluctuation
            self.state = state
        }
        
        public var imageName: String
        public var price: String
        public var tradeVolume: String
        public var fluctuationRate: String
        public var priceFluctuation: String
        public var state: Int
    }
    
    // Fixed non-changing proper
    public var coinName: String
}

struct UpCoinWidgetLiveActivity: Widget {
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: UpCoinWidgetAttributes.self) { context in
            
            let color = context.state.state > -1 ? (context.state.state == 0 ? Color.gray : Color.green) : Color.pink
            
            // Lock screen/banner UI goes here
            HStack {
                Spacer()
                HStack {
                    Image(context.state.imageName)
                        .resizable()
                        .frame(width: 12, height: 30)
                        .scaledToFit()
                    
                    Text(context.attributes.coinName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white)
                }
                .padding(.leading, 12)
                Spacer()
                HStack {
                    VStack {
                        Spacer()
                        Text(context.state.price)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(color)
                        Spacer()
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
                Spacer()
                HStack {
                    VStack {
                        Spacer()
                        Text(context.state.priceFluctuation)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(color)
                        Text(context.state.tradeVolume)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Text(context.state.fluctuationRate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(color)
                }
                .padding(.trailing, 12)
                Spacer()
            }
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.red)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.coinName)
                        .font(.system(size: 12, weight: .heavy))
                        .padding(.leading, 12)
                        .padding(.top, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.price)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(context.state.state > -1 ? (context.state.state == 0 ? Color.gray : Color.green) : Color.pink)
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.fluctuationRate)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(context.state.state > -1 ? (context.state.state == 0 ? Color.gray : Color.green) : Color.pink)
                    // more content
                }
            } compactLeading: {
                Text(context.attributes.coinName)
                    .font(.system(size: 12, weight: .heavy))
            } compactTrailing: {
                Text(context.state.price)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(context.state.state > -1 ? (context.state.state == 0 ? Color.gray : Color.green) : Color.pink)
            } minimal: {
            }
            .widgetURL(URL(string: "upbit://"))
            .keylineTint(Color.red)
        }
    }
}

struct UpCoinWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = UpCoinWidgetAttributes(coinName: "비트코인")
    static let contentState = UpCoinWidgetAttributes.ContentState(
        imageName: "rise3",
        price: "38,000,000",
        tradeVolume: "123123123",
        fluctuationRate: "-1.2%",
        priceFluctuation: "-1,000,000",
        state: 1)
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
