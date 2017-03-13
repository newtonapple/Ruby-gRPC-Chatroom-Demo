require "chat/client"

class RandomBot
  MESSAGES = [
    "Wednesday is hump day, but has anyone asked the camel if he’s happy about it?",
    "I often see the time 11:11 or 12:34 on clocks.",
    "They got there early, and they got really good seats.",
    "Mary plays the piano.",
    "The lake is a long way from here.",
    "The quick brown fox jumps over the lazy dog.",
    "A song can make or ruin a person’s day if they let it get to them.",
    "If Purple People Eaters are real… where do they find purple people to eat?",
    "Yeah, I think it's a good environment for learning English.",
    "She works two jobs to make ends meet; at least, that was her reason for not having time to join us.",
    "A glittering gem is not enough.",
    "Cats are good pets, for they are clean and are not noisy.",
    "I currently have 4 windows open up… and I don’t know why.",
    "We need to rent a room for our party.",
    "He said he was not there yesterday; however, many people saw him there.",
    "The old apple revels in its authority.",
    "Sometimes, all you need to do is completely make an ass of yourself and laugh it off to realise that life isn’t so bad after all.",
    "She borrowed the book from him many years ago and hasn't yet returned it.",
    "Someone I know recently combined Maple Syrup & buttered Popcorn thinking it would taste like caramel popcorn. It didn’t and they don’t recommend anyone else do it either.",
    "I'd rather be a bird than a fish.",
    "Let me help you with your baggage.",
    "The waves were crashing on the shore; it was a lovely sight.",
    "Where do random thoughts come from?",
    "Wow, does that work?",
    "I am happy to take your donation; any amount will be greatly appreciated.",
    "Should we start class now, or should we wait for everyone to get here?",
    "She advised him to come back at once.",
    "I love eating toasted cheese and tuna sandwiches.",
    "My Mum tries to be cool by saying that she likes all the same things that I do.",
    "If the Easter Bunny and the Tooth Fairy had babies would they take your teeth and leave chocolate for you?",
    "The clock within this blog and the clock on my laptop are 1 hour different from each other.",
    "She did her best to help him.",
    "This is a Japanese doll.",
    "He didn’t want to go to the dentist, yet he went anyway.",
    "The stranger officiates the meal.",
    "I would have gotten the promotion, but my attendance wasn’t good enough.",
    "If you like tuna and tomato sauce- try combining the two. It’s really not as bad as it sounds.",
    "I think I will buy the red car, or I will lease the blue one.",
    "I checked to make sure that he was still alive.",
    "It was getting dark, and we weren’t there yet.",
    "I want to buy a onesie… but know it won’t suit me.",
    "I was very proud of my nickname throughout high school but today- I couldn’t be any different to what my nickname was.",
    "He turned in the research paper on Friday; otherwise, he would have not passed the class.",
    "What was the person thinking when they discovered cow’s milk was fine for human consumption… and why did they do it in the first place!?",
    "Check back tomorrow; I will see if the book has arrived.",
    "Sometimes it is better to just walk away from things and go back to them later when you’re in a better frame of mind.",
    "There were white out conditions in the town; subsequently, the roads were impassable.",
    "If I don’t like something, I’ll stay away from it.",
    "Joe made the sugar cookies; Susan decorated them.",
    "There was no ice cream in the freezer, nor did they have money to go to the store."
  ].freeze

  attr_reader :client

  def initialize(uri, session_id)
    @client = Chat::RegisteredClient.new(uri, session_id)
  end

  def run
    loop do
      sleep((rand * 5).round)
      msgs = MESSAGES.sample((rand * 5).round)
      msgs.each do |msg|
        @client.send msg
        puts @client.message_responses.next.inspect
      end
    end
  end
end
