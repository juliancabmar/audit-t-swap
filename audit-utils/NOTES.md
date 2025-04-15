Challenge Url: https://codehawks.cyfrin.io/c/2025-02-datingdapp/results?lt=contest&page=1&sc=xp&sj=reward&t=report

Busines Logic:
Is a Date DApp (like tinder) in what the owner recive a fee for every match.

Services:
- ensure genuine connections.
- turns every match into a meaningful, on-chain commitment.

Roles:
- User: is the one who create a NFT dating profile (NFTDP) and is looking for a match.

Dynamic:
1. User mint a NFT dating profile (NFTDP)
2. If another user like his profile, pay 1 ETH for give a "like" to his NFTDP 
3. The likes on the NFTDP are being acumulated until a match occurs
4. When a match occurs the both NFTDP funds (minus 10% of fee) are send to a shared access Wallet.
5. (How the fee is managed?)


+LikeRegistry::
    @audit L-15: profileNFT is public so can be called from an external contract
    @audit L-17: FIXEDFEE must be constant not immutable
    +LikeRegistry::constructor
        +SoulboundProfileNFT::constructor
    +LikeRegistry::likeUser
        +LikeRegistry::matchRewards
            +MultiSigWallet::constructor
    +LikeRegistry::getMatches
    +LikeRegistry::withdrawFees

+MultiSigWallet::
    +MultiSigWallet::submitTransaction
    @audit L-42: Must use a require or a more verbose custom error
    @audit L-43: Must use a require or a more verbose custom error
    +MultiSigWallet::approveTransaction
    @audit L-53: Txn must be memory not storage
    +MultiSigWallet::executeTransaction
    @audit L-70: Txn must be memory not storage

-SoulboundProfileNFT::
@audit L-22: Why _profiles is private if nothing on chain it is?
    +SoulboundProfileNFT::mintProfile
    +SoulboundProfileNFT::burnProfile
    +SoulboundProfileNFT::blockProfile
    +SoulboundProfileNFT::transferFrom
    +SoulboundProfileNFT::safeTransferFrom
    -SoulboundProfileNFT::tokenURI 
    @audit L-91: the casting is unnecesary