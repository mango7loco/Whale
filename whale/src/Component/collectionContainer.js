import React from "react";
import Box from "@material-ui/core/Box";
import CardMedia from "@material-ui/core/CardMedia";
import HappyKongz from "../images/HappyKongz.png";
import { Typography } from "@material-ui/core";

const CollectionContainer = () => {
  function clickEvent() {
    console.log("cliked!");
  }
  return (
    <Box
      onClick={clickEvent}
      sx={{
        boxShadow: "0 5px 10px 1px lightgray",
        width: 400,
        height: 500,
        backgroundColor: "white",
        textAlign: "center",
        borderRadius: "10%",
        position: "fixed",
        left: "68%",
        top: "25%",
        "&:hover": {
          backgroundColor: "primary.main",
          opacity: [0.9, 0.8, 0.7],
        },
        "& .MuiCardMedia-root": {
          borderRadius: "10% 10% 0 0",
        },
      }}
    >
      <CardMedia
        component="img"
        height="350"
        image={HappyKongz}
        alt="happy kongz"
      />
      <Typography variant="h4">Happy Kongz</Typography>
      <Typography variant="body1">This is sample </Typography>
    </Box>
  );
};

export default CollectionContainer;
