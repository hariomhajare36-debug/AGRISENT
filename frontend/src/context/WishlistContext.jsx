import React, { createContext, useContext, useState, useEffect } from 'react';

export const WishlistContext = createContext(null);

export const WishlistProvider = ({ children }) => {
  const [wishlist, setWishlist] = useState(() => {
    try {
      const saved = localStorage.getItem('agrirent_wishlist');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('agrirent_wishlist', JSON.stringify(wishlist));
    } catch (e) {
      console.error('Failed to sync wishlist to storage', e);
    }
  }, [wishlist]);

  const toggleWishlist = (item) => {
    setWishlist((prev) => {
      const exists = prev.some((x) => x.id === item.id);
      if (exists) {
        return prev.filter((x) => x.id !== item.id);
      } else {
        return [...prev, item];
      }
    });
  };

  const isInWishlist = (id) => {
    return wishlist.some((x) => x.id === id);
  };

  const removeFromWishlist = (id) => {
    setWishlist((prev) => prev.filter((x) => x.id !== id));
  };

  const clearWishlist = () => {
    setWishlist([]);
  };

  return (
    <WishlistContext.Provider
      value={{
        wishlist,
        wishlistCount: wishlist.length,
        toggleWishlist,
        isInWishlist,
        removeFromWishlist,
        clearWishlist
      }}
    >
      {children}
    </WishlistContext.Provider>
  );
};

export const useWishlist = () => {
  const context = useContext(WishlistContext);
  if (!context) {
    throw new Error('useWishlist must be used within a WishlistProvider');
  }
  return context;
};
