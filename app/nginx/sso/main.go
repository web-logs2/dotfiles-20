package main

import (
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

func basicAuth(next http.HandlerFunc) http.HandlerFunc {
	expectedUsernameHash := sha256.Sum256([]byte(os.Getenv("LOGIN_USERNAME")))
	expectedPasswordHash := sha256.Sum256([]byte(os.Getenv("LOGIN_PASSWORD")))

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		username, password, ok := r.BasicAuth()
		if ok {
			usernameHash := sha256.Sum256([]byte(username))
			passwordHash := sha256.Sum256([]byte(password))

			usernameMatch := subtle.ConstantTimeCompare(usernameHash[:], expectedUsernameHash[:]) == 1
			passwordMatch := subtle.ConstantTimeCompare(passwordHash[:], expectedPasswordHash[:]) == 1
			if usernameMatch && passwordMatch {
				next.ServeHTTP(w, r)
				return
			}
		}

		w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
	})
}

var salt = []byte(os.Getenv("SSO_TOKEN_SALT"))

func hashAndSalt(s string) string {
	hash := sha256.Sum256(append(salt, []byte(s)...))
	return hex.EncodeToString(hash[:])
}

func cookieAuth(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		err := func() error {
			ssoTokenCookie, err := r.Cookie("SSO_TOKEN")
			if err != nil {
				return err
			}
			spl := strings.SplitN(ssoTokenCookie.Value, ".", 2)
			if len(spl) != 2 {
				return errors.New("token format error")
			}
			if hashAndSalt(spl[1]) != spl[0] {
				return errors.New("token invalid error")
			}
			expireUnix, err := strconv.Atoi(spl[1])
			if err != nil {
				return err
			}
			if time.Now().Unix() > int64(expireUnix) {
				return errors.New("token expire error")
			}
			return nil
		}()
		if err != nil {
			log.Println(err)
			w.WriteHeader(http.StatusUnauthorized)
			w.Write([]byte("Unauthorized"))
		} else {
			next(w, r)
		}
	})
}

func setAuthCookie(w http.ResponseWriter) {
	expire := time.Now().Add(time.Hour * 24 * 50)
	s := strconv.Itoa(int(expire.Unix()))
	token := fmt.Sprintf("%s.%s", hashAndSalt(s), s)
	http.SetCookie(w, &http.Cookie{
		Name:     "SSO_TOKEN",
		Value:    token,
		Path:     "/",
		Domain:   os.Getenv("SSO_COOKIE_DOMAIN"),
		Expires:  expire,
		Secure:   false,
		HttpOnly: true,
	})
}

func main() {
	http.HandleFunc("/", cookieAuth(func(w http.ResponseWriter, r *http.Request) {
		cookie := r.Header.Get("cookie")
		w.Write([]byte("cookie: " + cookie))
	}))
	http.HandleFunc("/auth", cookieAuth(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	http.HandleFunc("/login", basicAuth(func(w http.ResponseWriter, r *http.Request) {
		setAuthCookie(w)
		getRedirectURL := func() string {
			redirectCookie, err := r.Cookie("redirect")
			if err != nil {
				return ""
			}
			return redirectCookie.Value
		}
		http.Redirect(w, r, getRedirectURL(), http.StatusFound)
	}))
	addr := fmt.Sprintf(os.Getenv("LISTEN_ADDR"))
	if addr == "" {
		addr = "127.0.0.1:3100"
	}
	http.ListenAndServe(addr, nil)
}
