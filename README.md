# Ininite Grant Garden

A simple NFT contract to help solve some problems with grants funding by implementing an infinite garden.

## The Mechanism

1. Anyone can create a proposal, which means paying the cost to mint an NFT.
2. This NFT is displayed on a web page - the infinite garden.
3. Stewards of this NFT can update the tokenURI to whatever they like to represent ongoing progress with their pplication and work.
4. Anyone can vote on any NFT.
5. Voting costs ETH.
6. Upvotes are added to the "rank" of the grant.
7. Downvotes subtract from the rank.
8. The "gardener" of the contract (ideally a grants DAO or other such organisation) can either **harvest** or **prune** grants.
9. Harvesting means paying out a grant. Pruning means removing the grant from the directory and burning the NFT.
10. If a grant you upvoted gets harvested, you share in a portion of the rewards depending on how much you voted with.
11. If a grant you downvoted gets pruned, you get your money back plus a share of whatever upvotes were added to that grant by others.

## Future Plans

Obviously, build a proper front end which displays the NFTs and reveals the garden in all its glory.

Create a subgraph to make accessing this data easy for everyone.

Ideally, in the long term, we'd like to develop a full-blown curation mechanism with its own token that works along similar lines to [dap.ps](https://dap.ps), but in a less specific and restrained way. We sense that using some kind of demurrage to encourage people to contribute to "informational spaces" and their curation is a truly interesting direction to take, but this requires more research than can be done in a weekend.
