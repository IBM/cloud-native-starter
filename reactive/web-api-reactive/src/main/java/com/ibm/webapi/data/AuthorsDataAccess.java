package com.ibm.webapi.data;

import com.ibm.webapi.business.Author;
import com.ibm.webapi.business.NonexistentAuthor;

public interface AuthorsDataAccess {
	public Author getAuthor(String name) throws NoConnectivity, NonexistentAuthor;
}