package leedm777.bacon.model

import net.liftweb.mapper.{IdPK, LongKeyedMapper, LongKeyedMetaMapper}

class Player extends LongKeyedMapper[Player] with IdPK {
  def getSingleton = Player
}

object Player extends Player with LongKeyedMetaMapper[Player]
