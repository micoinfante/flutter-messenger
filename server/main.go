package main

import (
	"context"
	"fmt"
	"log"
	"messenger/server/pkg/protocol/grpc"
	v1 "messenger/server/pkg/service/v1"
	"os"
)

func main() {
	if err := grpc.RunServer(context.Background(), v1.NewChatServiceServer(), "3000"); err != nil {
		_, err2 := fmt.Fprintf(os.Stderr, "%v\n\n", err)
		if err2 != nil {
			log.Println("Error print", err2)
			return
		}
		log.Fatalln("Error encoutered ", err)
		// os.Exit(1)
	}
	log.Println("GRPC server running on port 3000")
}
