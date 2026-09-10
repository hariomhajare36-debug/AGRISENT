import React, { createContext, useContext, useState, useEffect } from 'react';

export const CompareContext = createContext(null);

export const CompareProvider = ({ children }) => {
  const [compareList, setCompareList] = useState(() => {
    try {
      const saved = localStorage.getItem('agrirent_compare');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('agrirent_compare', JSON.stringify(compareList));
    } catch (e) {
      console.error('Failed to sync compare list to storage', e);
    }
  }, [compareList]);

  const addToCompare = (item) => {
    if (compareList.length >= 4) {
      alert('You can compare up to 4 machines simultaneously. Please remove one to add another.');
      return false;
    }
    if (!compareList.some((x) => x.id === item.id)) {
      setCompareList((prev) => [...prev, item]);
      return true;
    }
    return false;
  };

  const removeFromCompare = (id) => {
    setCompareList((prev) => prev.filter((x) => x.id !== id));
  };

  const isInCompare = (id) => {
    return compareList.some((x) => x.id === id);
  };

  const toggleCompare = (item) => {
    if (isInCompare(item.id)) {
      removeFromCompare(item.id);
      return false;
    } else {
      return addToCompare(item);
    }
  };

  const clearCompare = () => {
    setCompareList([]);
  };

  return (
    <CompareContext.Provider
      value={{
        compareList,
        compareCount: compareList.length,
        addToCompare,
        removeFromCompare,
        isInCompare,
        toggleCompare,
        clearCompare
      }}
    >
      {children}
    </CompareContext.Provider>
  );
};

export const useCompare = () => {
  const context = useContext(CompareContext);
  if (!context) {
    throw new Error('useCompare must be used within a CompareProvider');
  }
  return context;
};
