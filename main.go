package main

import (
	"fmt"
	"log"
	"regexp"
	"sort"

	"github.com/go-git/go-git/v5"
	_ "github.com/go-git/go-git/v5/_examples"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/storage/memory"

	"github.com/hashicorp/go-version"
)

type byVersion []string

func (s byVersion) Len() int {
	return len(s)
}

func (s byVersion) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s byVersion) Less(i, j int) bool {
	v1, err := version.NewVersion(s[i])
	if err != nil {
		panic(err)
	}
	v2, err := version.NewVersion(s[j])
	if err != nil {
		panic(err)
	}
	return v1.LessThan(v2)
}

func main() {
	// url := "https://github.com/xxxserxxx/gotop"
	url := "https://github.com/golang/go"
	// Create the remote with repository URL
	rem := git.NewRemote(memory.NewStorage(), &config.RemoteConfig{
		Name: "origin",
		URLs: []string{url},
	})

	// We can then use every Remote functions to retrieve wanted information
	refs, err := rem.List(&git.ListOptions{
		// Returns all references, including peeled references.
		// PeelingOption: git.AppendPeeled,
	})
	if err != nil {
		log.Fatal(err)
	}

	// Filters the references list and only keeps tags
	prefix := "go"
	r, _ := regexp.Compile("^" + prefix)
	var tags []string
	for _, ref := range refs {
		if ref.Name().IsTag() {
			if r.MatchString(ref.Name().Short()) {
				tags = append(tags, ref.Name().Short())
			}
			// if strings.Contains(ref.Name().Short(), prefix) {
			// 	tags = append(tags, ref.Name().Short())
			// }
		}
	}
	// sort.Sort(byVersion(tags))
	sort.Strings(tags)
	versions := []string{"v1.4", "v1.12", "v1.20", "v1.8"}
	sort.Sort(byVersion(versions))
	fmt.Println(versions)

	if len(tags) == 0 {
		log.Println("No tags!")
		return
	}

	log.Printf("Tags found: %v", tags)
}
